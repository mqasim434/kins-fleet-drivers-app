import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/core/utils/auth_errors.dart';
import 'package:kins_fleet_drivers/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });

    test('email accepts valid address', () {
      expect(Validators.email('chauffeur@kins.nl'), isNull);
    });

    test('password requires minimum length', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('AuthErrors', () {
    test('web app roles use admin message', () {
      expect(AuthErrors.webAppRoles, contains('admin'));
      expect(AuthErrors.webAppRoles, contains('planner'));
      expect(AuthErrors.webAppRoles, contains('employee'));
    });
  });
}
