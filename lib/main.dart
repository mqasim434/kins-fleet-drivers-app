import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kins_fleet_drivers/app.dart';
import 'package:kins_fleet_drivers/core/firebase/firebase_bootstrap.dart';
import 'package:kins_fleet_drivers/features/startup/firebase_error_screen.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final firebaseError = await ensureFirebaseInitialized();

  if (firebaseError != null) {
    runApp(FirebaseErrorScreen(message: firebaseError));
    return;
  }

  runApp(const KinsDriverApp());
}
