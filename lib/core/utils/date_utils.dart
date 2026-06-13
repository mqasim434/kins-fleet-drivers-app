import 'package:intl/intl.dart';

/// nl-NL date/time formatting helpers.
abstract final class AppDateUtils {
  static const _locale = 'nl_NL';

  static String formatDate(DateTime date) {
    return DateFormat.yMMMMEEEEd(_locale).format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMMM yyyy', _locale).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat.Hm(_locale).format(date);
  }

  static String todayIso() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
