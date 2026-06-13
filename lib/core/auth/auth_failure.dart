import 'package:kins_fleet_drivers/core/l10n/auth_messages.dart';

class AuthFailure implements Exception {
  AuthFailure(this.messageKey);

  final AuthMessageKey messageKey;

  @override
  String toString() => messageKey.name;
}
