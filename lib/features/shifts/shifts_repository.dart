import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';

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

    return snapshot.docs
        .map((doc) => ShiftAssignment.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
