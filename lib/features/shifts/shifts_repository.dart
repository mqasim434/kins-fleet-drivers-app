import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/shifts/models/bus.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shift_sort.dart';

class ShiftsRepository {
  ShiftsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> countTodayShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final snapshot = await _firestore
        .collection('shiftAssignments')
        .where('driverId', isEqualTo: driverId)
        .where('date', isEqualTo: today)
        .get();
    return snapshot.docs.length;
  }

  Future<List<ShiftAssignment>> fetchTodayShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final snapshot = await _firestore
        .collection('shiftAssignments')
        .where('driverId', isEqualTo: driverId)
        .where('date', isEqualTo: today)
        .get();

    return sortShiftAssignments(
      snapshot.docs
          .map((doc) => ShiftAssignment.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<List<ShiftAssignment>> fetchUpcomingShifts(String driverId) async {
    final today = AppDateUtils.todayIso();
    final snapshot = await _firestore
        .collection('shiftAssignments')
        .where('driverId', isEqualTo: driverId)
        .where('date', isGreaterThanOrEqualTo: today)
        .get();

    return sortShiftAssignments(
      snapshot.docs
          .map((doc) => ShiftAssignment.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<ShiftAssignment?> fetchShiftById(String shiftId) async {
    final doc = await _firestore.collection('shiftAssignments').doc(shiftId).get();
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
