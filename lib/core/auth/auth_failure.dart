import 'package:kins_fleet_drivers/core/auth/models/driver_profile.dart';
import 'package:kins_fleet_drivers/core/auth/models/user_profile.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.driver,
  });

  final UserProfile user;
  final DriverProfile driver;
}

class AuthFailure implements Exception {
  AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
