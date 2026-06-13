import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/shifts/models/bus.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shift_sort.dart';

class ShiftsRepository {
  ShiftsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Single-field query on [driverId] only — works with driver security rules
  /// and avoids composite index requirements. Date filtering is done client-side.
  Future<List<ShiftAssignment>> _fetchAllForDriver(String driverId) async {
    final snapshot = await _firestore
        .collection('shiftAssignments')
        .where('driverId', isEqualTo: driverId)
        .get();

    return snapshot.docs
        .map((doc) => ShiftAssignment.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<int> countTodayShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final all = await _fetchAllForDriver(driverId);
    return all.where((assignment) => assignment.date == today).length;
  }

  Future<List<ShiftAssignment>> fetchTodayShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final all = await _fetchAllForDriver(driverId);
    return sortShiftAssignments(
      all.where((assignment) => assignment.date == today).toList(),
    );
  }

  Future<List<ShiftAssignment>> fetchUpcomingShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final all = await _fetchAllForDriver(driverId);
    return sortShiftAssignments(
      all.where((assignment) => assignment.date.compareTo(today) >= 0).toList(),
    );
  }

  Future<ShiftAssignment?> fetchShiftById(String shiftId) async {
    final doc =
        await _firestore.collection('shiftAssignments').doc(shiftId).get();
    if (!doc.exists) return null;
    return ShiftAssignment.fromFirestore(doc.id, doc.data()!);
  }

  Future<Bus?> fetchBus(String busId) async {
    if (busId.isEmpty) return null;
    final doc = await _firestore.collection('buses').doc(busId).get();
    if (!doc.exists) return null;
    return Bus.fromFirestore(doc.id, doc.data()!);
  }
}
