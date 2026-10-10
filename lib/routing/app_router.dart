import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/features/account/account_screen.dart';
import 'package:kins_fleet_drivers/features/clock/clock_screen.dart';
import 'package:kins_fleet_drivers/features/auth/forgot_password_screen.dart';
import 'package:kins_fleet_drivers/features/auth/login_screen.dart';
import 'package:kins_fleet_drivers/features/buses/bus_photos_screen.dart';
import 'package:kins_fleet_drivers/features/buses/buses_screen.dart';
import 'package:kins_fleet_drivers/features/damage/damage_screen.dart';
import 'package:kins_fleet_drivers/features/home/home_screen.dart';
import 'package:kins_fleet_drivers/features/photos/capture_screen.dart';
import 'package:kins_fleet_drivers/features/photos/photos_screen.dart';
import 'package:kins_fleet_drivers/features/vehicle/vehicle_screen.dart';
import 'package:kins_fleet_drivers/features/work/shift_detail_screen.dart';
import 'package:kins_fleet_drivers/features/work/work_screen.dart';
import 'package:kins_fleet_drivers/features/onboarding/onboarding_form_screen.dart';
import 'package:kins_fleet_drivers/features/onboarding/onboarding_screen.dart';
import 'package:kins_fleet_drivers/features/splash/splash_screen.dart';
import 'package:kins_fleet_drivers/shell/driver_shell.dart';

GoRouter createRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      if (auth.initializing) {
        return path == '/splash' ? null : '/splash';
      }
      final signingIn = path == '/login' || path == '/forgot';
      if (auth.session == null) return signingIn ? null : '/login';
      if (signingIn || path == '/splash') {
        return auth.session!.user.canOnboard ? '/onboard' : '/home';
      }
      final staff = auth.session!.user.canOnboard;
      final onboardingPath = path == '/onboard' || path.startsWith('/onboard/');
      if (staff) return onboardingPath ? null : '/onboard';
      if (onboardingPath) return '/home';
      final fleetManager = auth.session!.user.isFleetManager;
      final allowClock = auth.session!.driver?.allowAppClock == true;
      if (!fleetManager && (path == '/buses' || path.startsWith('/buses/'))) return '/home';
      if (!allowClock && path == '/clock') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const OnboardingFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => OnboardingFormScreen(
              candidateId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DriverShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/work',
            builder: (context, state) => const WorkScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => ShiftDetailScreen(
                  shiftId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/vehicle',
            builder: (context, state) => const VehicleScreen(),
          ),
          GoRoute(
            path: '/buses',
            builder: (context, state) => const BusesScreen(),
            routes: [
              GoRoute(
                path: ':busId',
                builder: (context, state) => BusPhotosScreen(
                  busId: state.pathParameters['busId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/photos',
            builder: (context, state) => const PhotosScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => CaptureScreen(
                  initialPurpose: state.uri.queryParameters['purpose'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/damage',
            builder: (context, state) => const DamageScreen(),
          ),
          GoRoute(
            path: '/clock',
            builder: (context, state) => const ClockScreen(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
    ],
  );
}
