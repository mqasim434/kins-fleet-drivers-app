import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/features/auth/forgot_password_screen.dart';
import 'package:kins_fleet_drivers/features/auth/login_screen.dart';
import 'package:kins_fleet_drivers/features/dashboard/dashboard_screen.dart';
import 'package:kins_fleet_drivers/features/profile/profile_screen.dart';
import 'package:kins_fleet_drivers/features/splash/splash_screen.dart';
import 'package:kins_fleet_drivers/routing/routes.dart';
import 'package:kins_fleet_drivers/widgets/app_shell.dart';
import 'package:kins_fleet_drivers/widgets/module_placeholder_screen.dart';

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
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.shifts,
            builder: (context, state) => const ModulePlaceholderScreen(
              title: 'Mijn diensten',
              moduleNumber: 3,
              icon: Icons.calendar_today_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.photos,
            builder: (context, state) => const ModulePlaceholderScreen(
              title: "Busfoto's",
              moduleNumber: 4,
              icon: Icons.photo_camera_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.handovers,
            builder: (context, state) => const ModulePlaceholderScreen(
              title: 'Overdrachten',
              moduleNumber: 5,
              icon: Icons.swap_horiz_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.damage,
            builder: (context, state) => const ModulePlaceholderScreen(
              title: 'Schade melden',
              moduleNumber: 6,
              icon: Icons.report_outlined,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Pagina niet gevonden: ${state.uri}'),
      ),
    ),
  );
}
