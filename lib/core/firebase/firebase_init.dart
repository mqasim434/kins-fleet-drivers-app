import 'package:firebase_core/firebase_core.dart';
import 'package:kins_fleet_drivers/firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
