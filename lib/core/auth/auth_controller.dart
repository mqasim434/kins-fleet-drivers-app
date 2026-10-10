import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/core/auth/auth_repository.dart';
import 'package:kins_fleet_drivers/core/auth/session.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;
  StreamSubscription<User?>? _subscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _driverSub;
  String? _watchedDriverId;
  Timer? _startupWatchdog;

  AuthSession? session;
  bool initializing = true;
  bool busy = false;

  void start() {
    if (_subscription != null) return;
    try {
      _subscription = _repository.authStateChanges.listen(
        _onAuth,
        onError: (_) => _finishStartup(null),
      );
    } catch (_) {
      _finishStartup(null);
      return;
    }

    // Physical devices sometimes delay the first authStateChanges event.
    _startupWatchdog = Timer(const Duration(seconds: 10), () {
      if (initializing) {
        if (kDebugMode) {
          debugPrint('AuthController: startup timed out, continuing logged out');
        }
        _finishStartup(null);
      }
    });

    unawaited(_bootstrapCurrentUser());
  }

  Future<void> _bootstrapCurrentUser() async {
    await Future<void>.delayed(Duration.zero);
    if (!initializing) return;
    final user = _repository.currentUser;
    if (user != null) {
      await _onAuth(user);
    }
  }

  Future<void> _onAuth(User? user) async {
    try {
      if (user == null) {
        await _driverSub?.cancel();
        _driverSub = null;
        _watchedDriverId = null;
        _finishStartup(null);
        return;
      }
      if (session?.user.uid == user.uid) {
        if (session!.driver != null) _watchDriver(session!);
        _finishStartup(session);
        return;
      }
      final restored = await _repository
          .restoreSession(user)
          .timeout(const Duration(seconds: 12));
      if (restored?.driver != null) _watchDriver(restored!);
      _finishStartup(restored);
    } catch (_) {
      _finishStartup(null);
    }
  }

  void _finishStartup(AuthSession? next) {
    _startupWatchdog?.cancel();
    _startupWatchdog = null;
    session = next;
    initializing = false;
    notifyListeners();
  }

  void _watchDriver(AuthSession loaded) {
    final driverId = loaded.driver?.id;
    if (driverId == null || driverId.isEmpty) return;
    if (_watchedDriverId == driverId && _driverSub != null) return;
    _driverSub?.cancel();
    _watchedDriverId = driverId;
    _driverSub = FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || session == null) return;
      session = AuthSession(
        user: session!.user,
        driver: DriverRecord.fromFirestore(snap.id, snap.data()!),
      );
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    busy = true;
    notifyListeners();
    try {
      session = await _repository.signIn(email: email, password: password);
      return null;
    } on AuthException catch (error) {
      return error.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordReset(email);
      return null;
    } on AuthException catch (error) {
      return error.message;
    }
  }

  Future<void> signOut() => _repository.signOut();

  @override
  void dispose() {
    _startupWatchdog?.cancel();
    _subscription?.cancel();
    _driverSub?.cancel();
    super.dispose();
  }
}
