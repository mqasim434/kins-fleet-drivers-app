import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/core/auth/auth_failure.dart';
import 'package:kins_fleet_drivers/core/auth/auth_repository.dart';
import 'package:kins_fleet_drivers/core/auth/models/driver_profile.dart';
import 'package:kins_fleet_drivers/core/auth/models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;
  StreamSubscription<User?>? _subscription;

  bool isInitializing = true;
  bool isBusy = false;
  UserProfile? user;
  DriverProfile? driver;
  String? loginError;

  bool get isAuthenticated => user != null && driver != null;

  String get driverDisplayName => driver?.displayName ?? user?.name ?? '';

  Future<void> initialize() async {
    final ready = Completer<void>();

    void finishInit() {
      if (!ready.isCompleted) {
        isInitializing = false;
        ready.complete();
      }
    }

    _subscription = _repository.authStateChanges.listen((firebaseUser) async {
      await _handleAuthUser(firebaseUser);
      finishInit();
      notifyListeners();
    });

    // Fallback when auth stream is slow to emit on cold start.
    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      await _handleAuthUser(currentUser);
      finishInit();
      notifyListeners();
    }

    await ready.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        isInitializing = false;
        notifyListeners();
      },
    );
  }

  Future<void> _handleAuthUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      driver = null;
      return;
    }

    if (user?.uid == firebaseUser.uid && driver != null) {
      return;
    }

    final session = await _repository.restoreSession(firebaseUser);
    if (session != null) {
      user = session.user;
      driver = session.driver;
    } else {
      user = null;
      driver = null;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isBusy = true;
    loginError = null;
    notifyListeners();

    try {
      final session = await _repository.signIn(
        email: email,
        password: password,
      );
      user = session.user;
      driver = session.driver;
      return true;
    } on AuthFailure catch (error) {
      loginError = error.message;
      user = null;
      driver = null;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    isBusy = true;
    loginError = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on AuthFailure catch (error) {
      loginError = error.message;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    user = null;
    driver = null;
    loginError = null;
    notifyListeners();
  }

  void clearLoginError() {
    loginError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
