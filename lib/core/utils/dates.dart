const _months = [
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];

const _weekdays = [
  'maandag',
  'dinsdag',
  'woensdag',
  'donderdag',
  'vrijdag',
  'zaterdag',
  'zondag',
];

String todayIso() {
  final now = DateTime.now();
  return isoDate(now);
}

String isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class IsoWeek {
  const IsoWeek({required this.year, required this.week});

  final int year;
  final int week;
}

/// ISO week of a local calendar day. Week 1 contains the first Thursday.
IsoWeek isoWeekOf(DateTime date) {
  final utc = DateTime.utc(date.year, date.month, date.day);
  final thursday = utc.add(Duration(days: DateTime.thursday - utc.weekday));
  final yearStart = DateTime.utc(thursday.year, 1, 1);
  final week = 1 + (thursday.difference(yearStart).inDays ~/ 7);
  return IsoWeek(year: thursday.year, week: week);
}

IsoWeek currentIsoWeek() => isoWeekOf(DateTime.now());

String formatIsoDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return iso;
  final date = DateTime(year, month, day);
  final weekday = _weekdays[date.weekday - 1];
  return '$weekday $day ${_months[month - 1]}';
}
