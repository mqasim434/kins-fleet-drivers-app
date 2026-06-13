import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/app.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_repository.dart';
import 'package:kins_fleet_drivers/core/firebase/firebase_init.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/features/dashboard/dashboard_provider.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_provider.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';
import 'package:kins_fleet_drivers/features/photos/photos_provider.dart';
import 'package:kins_fleet_drivers/features/photos/photos_repository.dart';
import 'package:kins_fleet_drivers/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await initializeDateFormatting('nl_NL');
  await initializeDateFormatting('en_US');

  final localeProvider = LocaleProvider();
  await localeProvider.load();

  final authRepository = AuthRepository();
  final authProvider = AuthProvider(authRepository);
  await authProvider.initialize();

  final shiftsRepository = ShiftsRepository();
  final photosRepository = PhotosRepository(shiftsRepository: shiftsRepository);
  final dashboardProvider = DashboardProvider(shiftsRepository);
  final shiftsProvider = ShiftsProvider(shiftsRepository);
  final photosProvider = PhotosProvider(photosRepository);

  final router = createAppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        Provider<ShiftsRepository>.value(value: shiftsRepository),
        ChangeNotifierProvider<DashboardProvider>.value(
          value: dashboardProvider,
        ),
        ChangeNotifierProvider<ShiftsProvider>.value(value: shiftsProvider),
        ChangeNotifierProvider<PhotosProvider>.value(value: photosProvider),
      ],
      child: KinsFleetDriversApp(router: router),
    ),
  );
}
