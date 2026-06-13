import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String formatDate(DateTime date, String localeTag) {
    return DateFormat.yMMMMEEEEd(localeTag).format(date);
  }

  static String formatShortDate(DateTime date, String localeTag) {
    return DateFormat.yMMMMd(localeTag).format(date);
  }

  static String formatTime(DateTime date, String localeTag) {
    return DateFormat.Hm(localeTag).format(date);
  }

  static String todayIso() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
