import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/photo_quality.dart';

void main() {
  test('ISO week 41 of 2026 starts on Monday 5 October', () {
    final week = isoWeekOf(DateTime(2026, 10, 5));
    expect(week.year, 2026);
    expect(week.week, 41);
    expect(isoWeekOf(DateTime(2026, 10, 7)).week, 41);
    expect(isoWeekOf(DateTime(2026, 10, 4)).week, 40);
  });

  test('a photo counts when it is marked good or large enough', () {
    expect(
      photoCountsAsGood(qualityOk: true, width: 100, height: 100, fileSize: 10),
      isTrue,
    );
    expect(
      photoCountsAsGood(qualityOk: false, width: 1600, height: 900, fileSize: 10),
      isTrue,
    );
    expect(
      photoCountsAsGood(qualityOk: false, width: 0, height: 0, fileSize: 100000),
      isTrue,
    );
    expect(
      photoCountsAsGood(qualityOk: false, width: 400, height: 300, fileSize: 20000),
      isFalse,
    );
  });
}
