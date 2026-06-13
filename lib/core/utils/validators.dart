import 'package:kins_fleet_drivers/l10n/app_localizations.dart';

abstract final class Validators {
  static String? email(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n.validationEmailRequired;
    }
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.validationPasswordRequired;
    }
    if (value.length < 6) {
      return l10n.validationPasswordMinLength;
    }
    return null;
  }

  static String? requiredField(
    String? value,
    String label,
    AppLocalizations l10n,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(label);
    }
    return null;
  }
}
