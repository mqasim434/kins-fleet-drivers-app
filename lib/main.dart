import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/firebase/firebase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const KinsFleetDriversApp());
}

class KinsFleetDriversApp extends StatelessWidget {
  const KinsFleetDriversApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KINS Fleet Chauffeur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF0B2E44),
        ),
        useMaterial3: true,
      ),
      home: const _FirebaseReadyScreen(),
    );
  }
}

class _FirebaseReadyScreen extends StatelessWidget {
  const _FirebaseReadyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KINS Fleet Chauffeur'),
        backgroundColor: const Color(0xFF0B2E44),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 64),
            SizedBox(height: 16),
            Text(
              'Firebase geïnitialiseerd',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Project: kins-fleet-app'),
          ],
        ),
      ),
    );
  }
}
