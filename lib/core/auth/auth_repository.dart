import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kins_fleet_drivers/core/auth/auth_failure.dart';
import 'package:kins_fleet_drivers/core/auth/models/driver_profile.dart';
import 'package:kins_fleet_drivers/core/auth/models/user_profile.dart';
import 'package:kins_fleet_drivers/core/utils/auth_errors.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthFailure('Inloggen mislukt. Probeer het opnieuw.');
      }
      return _loadAndValidateSession(user);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(AuthErrors.fromFirebaseAuth(error));
    } on AuthFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw AuthFailure(
        error.message ?? 'Netwerkfout. Controleer uw verbinding en probeer opnieuw.',
      );
    }
  }

  Future<AuthSession?> restoreSession(User user) async {
    try {
      return await _loadAndValidateSession(user);
    } on AuthFailure {
      await _auth.signOut();
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(AuthErrors.fromFirebaseAuth(error));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AuthSession> _loadAndValidateSession(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _auth.signOut();
      throw AuthFailure(AuthErrors.missingProfileMessage);
    }

    final profile = UserProfile.fromFirestore(user.uid, userDoc.data()!);

    if (!profile.isDriver) {
      await _auth.signOut();
      if (AuthErrors.webAppRoles.contains(profile.role)) {
        throw AuthFailure(AuthErrors.adminAppMessage);
      }
      throw AuthFailure(AuthErrors.adminAppMessage);
    }

    if (!profile.isActive) {
      await _auth.signOut();
      throw AuthFailure(AuthErrors.inactiveAccountMessage);
    }

    if (profile.driverId.isEmpty) {
      await _auth.signOut();
      throw AuthFailure(AuthErrors.missingDriverLinkMessage);
    }

    final driverDoc =
        await _firestore.collection('drivers').doc(profile.driverId).get();

    if (!driverDoc.exists) {
      await _auth.signOut();
      throw AuthFailure(AuthErrors.missingDriverMessage);
    }

    return AuthSession(
      user: profile,
      driver: DriverProfile.fromFirestore(driverDoc.id, driverDoc.data()!),
    );
  }
}
