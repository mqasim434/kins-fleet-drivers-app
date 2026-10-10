import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/config/app_theme.dart';
import 'package:kins_fleet_drivers/routing/app_router.dart';
import 'package:provider/provider.dart';

class KinsDriverApp extends StatefulWidget {
  const KinsDriverApp({super.key});

  @override
  State<KinsDriverApp> createState() => _KinsDriverAppState();
}

class _KinsDriverAppState extends State<KinsDriverApp> {
  late final AuthController _auth = AuthController()..start();
  late final _router = createRouter(_auth);

  @override
  void initState() {
    super.initState();
    // Always dismiss the OS splash after the first Flutter frame. Waiting for
    // auth on release builds left a blank window on some physical devices.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'KINS Chauffeur',
        theme: buildAppTheme(),
        themeMode: ThemeMode.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ColoredBox(
            color: AppColors.surface,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
