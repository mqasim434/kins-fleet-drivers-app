import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('nl');

  Locale get locale => _locale;

  String get dateLocaleTag =>
      _locale.languageCode == 'nl' ? 'nl_NL' : 'en_US';

  bool get isDutch => _locale.languageCode == 'nl';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'nl';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setDutch() => setLocale(const Locale('nl'));

  Future<void> setEnglish() => setLocale(const Locale('en'));
}

extension StatusLabels on AppLocalizations {
  String userStatus(String? status) => switch (status) {
        'active' => statusActive,
        'inactive' => statusInactive,
        'unavailable' => statusUnavailable,
        _ => status ?? emptyValue,
      };

  String shiftStatus(String? status) => switch (status) {
        'scheduled' => shiftScheduled,
        'completed' => shiftCompleted,
        'cancelled' => shiftCancelled,
        _ => status ?? emptyValue,
      };

  String busStatus(String? status) => switch (status) {
        'available' => statusAvailable,
        'inactive' => statusInactive,
        'unavailable' || 'not_available' => statusUnavailable,
        _ => status ?? emptyValue,
      };

  String damageStatus(String? status) => switch (status) {
        'reported' => damageReported,
        'confirmed' => damageConfirmed,
        'repaired' => damageRepaired,
        _ => status ?? emptyValue,
      };

  String severity(String? value) => switch (value) {
        'low' => severityLow,
        'medium' => severityMedium,
        'high' => severityHigh,
        _ => value ?? emptyValue,
      };
}
