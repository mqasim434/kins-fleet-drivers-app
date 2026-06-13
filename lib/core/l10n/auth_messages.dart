import 'package:firebase_auth/firebase_auth.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';

enum AuthMessageKey {
  adminApp,
  inactiveAccount,
  missingProfile,
  missingDriver,
  missingDriverLink,
  signInFailed,
  networkError,
  invalidEmail,
  userDisabled,
  wrongCredentials,
  tooManyRequests,
  missingPassword,
  genericError,
}

extension AuthMessageKeyLocalization on AuthMessageKey {
  String localize(AppLocalizations l10n) => switch (this) {
        AuthMessageKey.adminApp => l10n.errorAdminApp,
        AuthMessageKey.inactiveAccount => l10n.errorInactiveAccount,
        AuthMessageKey.missingProfile => l10n.errorMissingProfile,
        AuthMessageKey.missingDriver => l10n.errorMissingDriver,
        AuthMessageKey.missingDriverLink => l10n.errorMissingDriverLink,
        AuthMessageKey.signInFailed => l10n.errorSignInFailed,
        AuthMessageKey.networkError => l10n.errorNetwork,
        AuthMessageKey.invalidEmail => l10n.errorInvalidEmail,
        AuthMessageKey.userDisabled => l10n.errorUserDisabled,
        AuthMessageKey.wrongCredentials => l10n.errorWrongCredentials,
        AuthMessageKey.tooManyRequests => l10n.errorTooManyRequests,
        AuthMessageKey.missingPassword => l10n.errorMissingPassword,
        AuthMessageKey.genericError => l10n.errorGeneric,
      };
}

abstract final class AuthErrors {
  static const webAppRoles = {'admin', 'planner', 'employee'};

  static AuthMessageKey fromFirebaseAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AuthMessageKey.invalidEmail;
      case 'user-disabled':
        return AuthMessageKey.userDisabled;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthMessageKey.wrongCredentials;
      case 'too-many-requests':
        return AuthMessageKey.tooManyRequests;
      case 'network-request-failed':
        return AuthMessageKey.networkError;
      case 'missing-password':
        return AuthMessageKey.missingPassword;
      default:
        return AuthMessageKey.genericError;
    }
  }
}
