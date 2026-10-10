import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/models.dart';

void main() {
  test('iso date uses local calendar day', () {
    expect(isoDate(DateTime(2026, 10, 6)), '2026-10-06');
  });

  test('cancelled shifts are marked and names come from planning', () {
    final shift = ShiftAssignment.fromFirestore('a1', {
      'date': '2026-10-06',
      'startTime': '08:00',
      'endTime': '16:00',
      'shiftName': 'Ochtend',
      'status': 'cancelled',
      'busNumber': '12',
      'licensePlate': 'AB-123-C',
    });
    expect(shift.isCancelled, isTrue);
    expect(shift.timeLabel, '08:00 – 16:00');
    expect(shift.vehicleLabel, '12 · AB-123-C');
  });
}
