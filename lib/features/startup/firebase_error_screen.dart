import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kins_fleet_drivers/app.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/firebase/firebase_bootstrap.dart';

class FirebaseErrorScreen extends StatefulWidget {
  const FirebaseErrorScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  State<FirebaseErrorScreen> createState() => _FirebaseErrorScreenState();
}

class _FirebaseErrorScreenState extends State<FirebaseErrorScreen> {
  bool _retrying = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  Future<void> _retry() async {
    setState(() {
      _retrying = true;
      _message = null;
    });

    final error = await ensureFirebaseInitialized();

    if (!mounted) return;

    if (error == null) {
      runApp(const KinsDriverApp());
      return;
    }

    setState(() {
      _retrying = false;
      _message = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bordeaux),
      ),
      home: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: AppColors.bordeaux.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  _message ?? widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.ink,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _retrying ? null : _retry,
                  child: Text(_retrying ? 'Bezig…' : 'Opnieuw proberen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
