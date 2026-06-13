import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/app.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_repository.dart';
import 'package:kins_fleet_drivers/core/firebase/firebase_init.dart';
import 'package:kins_fleet_drivers/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await initializeDateFormatting('nl_NL');

  final authRepository = AuthRepository();
  final authProvider = AuthProvider(authRepository);
  await authProvider.initialize();

  final router = createAppRouter(authProvider);

  runApp(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: KinsFleetDriversApp(router: router),
    ),
  );
}
