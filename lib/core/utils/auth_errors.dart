import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase Auth error codes to Dutch user-facing messages.
abstract final class AuthErrors {
  static const adminAppMessage =
      'Dit account is voor de beheerders-app. Gebruik de KINS Fleet web-app.';
  static const inactiveAccountMessage =
      'Uw account is niet actief. Neem contact op met een beheerder.';
  static const missingProfileMessage =
      'Geen gebruikersprofiel gevonden. Neem contact op met een beheerder.';
  static const missingDriverMessage =
      'Chauffeurprofiel niet gevonden. Neem contact op met een beheerder.';
  static const missingDriverLinkMessage =
      'Geen chauffeur gekoppeld aan dit account. Neem contact op met een beheerder.';

  static const webAppRoles = {'admin', 'planner', 'employee'};

  static String fromFirebaseAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Voer een geldig e-mailadres in.';
      case 'user-disabled':
        return 'Dit account is uitgeschakeld. Neem contact op met een beheerder.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Onjuist e-mailadres of wachtwoord.';
      case 'too-many-requests':
        return 'Te veel pogingen. Probeer het over een paar minuten opnieuw.';
      case 'network-request-failed':
        return 'Netwerkfout. Controleer uw verbinding en probeer opnieuw.';
      case 'missing-password':
        return 'Voer uw wachtwoord in.';
      default:
        return 'Er is iets misgegaan. Probeer het opnieuw.';
    }
  }
}
