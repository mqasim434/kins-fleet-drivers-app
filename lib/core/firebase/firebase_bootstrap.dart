import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/firebase_options.dart';

/// Initializes Firebase once. Returns a user-facing error message on failure.
Future<String?> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return null;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return null;
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app' ||
        error.message?.contains('duplicate-app') == true) {
      return null;
    }
    if (kDebugMode) {
      debugPrint('FirebaseException: ${error.code} ${error.message}');
    }
    return _friendlyMessage(error.code, error.message);
  } catch (error, stack) {
    if (kDebugMode) {
      debugPrint('Firebase init failed: $error\n$stack');
    }
    final text = error.toString();
    if (text.contains('TimeoutException')) {
      return 'Opstarten duurde te lang. Controleer uw internet en probeer opnieuw.';
    }
    return 'Firebase kon niet starten. Controleer internet en installeer de app opnieuw.';
  }
}

String _friendlyMessage(String code, String? message) {
  if (code == 'invalid-api-key' || message?.contains('API key') == true) {
    return 'Firebase-configuratie is ongeldig. Neem contact op met KINS support.';
  }
  return 'De app kon geen verbinding maken met Firebase. '
      'Controleer internet en probeer opnieuw.';
}
