import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';

void main() {
  test('ShiftAssignment parses Firestore document', () {
    final assignment = ShiftAssignment.fromFirestore('abc123', {
      'driverId': 'driver1',
      'driverName': 'Jan Jansen',
      'date': '2026-06-14',
      'shiftName': 'Ochtend',
      'startTime': '06:00',
      'endTime': '14:00',
      'busNumber': '101',
      'status': 'scheduled',
    });

    expect(assignment.id, 'abc123');
    expect(assignment.driverId, 'driver1');
    expect(assignment.date, '2026-06-14');
    expect(assignment.status, 'scheduled');
  });
}
