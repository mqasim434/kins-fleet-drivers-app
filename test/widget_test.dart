import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/core/l10n/auth_messages.dart';
import 'package:kins_fleet_drivers/core/utils/validators.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';

void main() {
  group('Validators', () {
    test('email rejects empty input (nl)', () {
      final l10n = lookupAppLocalizations(const Locale('nl'));
      expect(Validators.email('', l10n), isNotNull);
    });

    test('email accepts valid address (en)', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(Validators.email('chauffeur@kins.nl', l10n), isNull);
    });

    test('password requires minimum length', () {
      final l10n = lookupAppLocalizations(const Locale('nl'));
      expect(Validators.password('123', l10n), isNotNull);
      expect(Validators.password('123456', l10n), isNull);
    });
  });

  group('AuthErrors', () {
    test('web app roles are defined', () {
      expect(AuthErrors.webAppRoles, contains('admin'));
      expect(AuthErrors.webAppRoles, contains('planner'));
      expect(AuthErrors.webAppRoles, contains('employee'));
    });
  });
}
