import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shift_sort.dart';

void main() {
  test('sortShiftAssignments orders by date then startTime', () {
    const a = ShiftAssignment(
      id: '1',
      driverId: 'd1',
      driverName: 'Jan',
      departmentId: 'dep1',
      departmentName: 'A',
      shiftTypeId: 's1',
      shiftName: 'Ochtend',
      shiftColor: '#2563EB',
      date: '2026-06-15',
      startTime: '14:00',
      endTime: '22:00',
      busId: 'b1',
      busNumber: '101',
      licensePlate: 'AB-123',
      status: 'scheduled',
      notes: '',
    );
    const b = ShiftAssignment(
      id: '2',
      driverId: 'd1',
      driverName: 'Jan',
      departmentId: 'dep1',
      departmentName: 'A',
      shiftTypeId: 's1',
      shiftName: 'Middag',
      shiftColor: '#2563EB',
      date: '2026-06-14',
      startTime: '18:00',
      endTime: '02:00',
      busId: 'b1',
      busNumber: '102',
      licensePlate: 'CD-456',
      status: 'scheduled',
      notes: '',
    );
    const c = ShiftAssignment(
      id: '3',
      driverId: 'd1',
      driverName: 'Jan',
      departmentId: 'dep1',
      departmentName: 'A',
      shiftTypeId: 's1',
      shiftName: 'Vroeg',
      shiftColor: '#2563EB',
      date: '2026-06-14',
      startTime: '06:00',
      endTime: '14:00',
      busId: 'b1',
      busNumber: '103',
      licensePlate: 'EF-789',
      status: 'scheduled',
      notes: '',
    );

    final sorted = sortShiftAssignments([a, b, c]);

    expect(sorted.map((s) => s.id).toList(), ['3', '2', '1']);
  });
}
