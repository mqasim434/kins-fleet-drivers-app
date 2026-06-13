import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/config/app_theme.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';

class KinsFleetDriversApp extends StatelessWidget {
  const KinsFleetDriversApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'KINS Fleet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
