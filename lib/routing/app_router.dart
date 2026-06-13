import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/features/auth/forgot_password_screen.dart';
import 'package:kins_fleet_drivers/features/auth/login_screen.dart';
import 'package:kins_fleet_drivers/features/dashboard/dashboard_screen.dart';
import 'package:kins_fleet_drivers/features/splash/splash_screen.dart';
import 'package:kins_fleet_drivers/routing/routes.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isLogin = location == AppRoutes.login;
      final isForgotPassword = location == AppRoutes.forgotPassword;

      if (authProvider.isInitializing) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (!authProvider.isAuthenticated) {
        if (isLogin || isForgotPassword) return null;
        return AppRoutes.login;
      }

      if (isLogin || isSplash || isForgotPassword) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Pagina niet gevonden: ${state.uri}'),
      ),
    ),
  );
}
