import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';

List<ShiftAssignment> sortShiftAssignments(List<ShiftAssignment> shifts) {
  final sorted = List<ShiftAssignment>.from(shifts);
  sorted.sort((a, b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) return dateCompare;
    return a.startTime.compareTo(b.startTime);
  });
  return sorted;
}
