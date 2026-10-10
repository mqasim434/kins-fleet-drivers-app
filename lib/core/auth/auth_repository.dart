import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kins_fleet_drivers/core/auth/session.dart';

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
        throw AuthException('Aanmelden is mislukt.');
      }
      return _loadSession(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error.code));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Netwerkfout. Controleer uw verbinding.');
    }
  }

  Future<AuthSession?> restoreSession(User user) async {
    try {
      return await _loadSession(user);
    } on AuthException {
      await _auth.signOut();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AuthSession> _loadSession(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _auth.signOut();
      throw AuthException(
        'Uw account is nog niet door een beheerder geactiveerd.',
      );
    }

    final account = UserAccount.fromFirestore(user.uid, userDoc.data()!);
    if (account.canOnboard) {
      return AuthSession(user: account);
    }
    if (!account.isDriver) {
      await _auth.signOut();
      throw AuthException(
        'Dit account hoort bij het beheerdersdashboard, niet bij de chauffeur-app.',
      );
    }
    if (!account.isActive) {
      await _auth.signOut();
      throw AuthException('Dit account is uitgeschakeld.');
    }
    if (account.driverId.isEmpty) {
      await _auth.signOut();
      throw AuthException(
        'Dit account is niet gekoppeld aan een chauffeursdossier.',
      );
    }

    final driverDoc =
        await _firestore.collection('drivers').doc(account.driverId).get();
    if (!driverDoc.exists) {
      await _auth.signOut();
      throw AuthException('Het chauffeursdossier is niet gevonden.');
    }

    return AuthSession(
      user: account,
      driver: DriverRecord.fromFirestore(driverDoc.id, driverDoc.data()!),
    );
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Voer een geldig e-mailadres in.';
      case 'user-disabled':
        return 'Dit account is uitgeschakeld.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Onjuist e-mailadres of wachtwoord.';
      case 'too-many-requests':
        return 'Te veel pogingen. Probeer het later opnieuw.';
      case 'network-request-failed':
        return 'Netwerkfout. Controleer uw verbinding.';
      default:
        return 'Aanmelden is mislukt. Probeer het opnieuw.';
    }
  }
}
