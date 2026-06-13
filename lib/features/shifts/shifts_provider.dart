import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';

class ShiftsProvider extends ChangeNotifier {
  ShiftsProvider(this._repository);

  final ShiftsRepository _repository;

  List<ShiftAssignment> assignments = [];
  bool isLoading = false;
  bool hasError = false;
  String? debugError;

  Future<void> load(String driverId) async {
    if (driverId.isEmpty) return;

    isLoading = true;
    hasError = false;
    debugError = null;
    notifyListeners();

    try {
      assignments = await _repository.fetchUpcomingShifts(driverId);
    } on FirebaseException catch (error) {
      hasError = true;
      assignments = [];
      debugError = '${error.code}: ${error.message}';
      if (kDebugMode) {
        debugPrint('ShiftsProvider.load failed: $debugError');
      }
    } on Exception catch (error) {
      hasError = true;
      assignments = [];
      debugError = error.toString();
      if (kDebugMode) {
        debugPrint('ShiftsProvider.load failed: $debugError');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String driverId) => load(driverId);

  ShiftAssignment? findById(String id) {
    for (final assignment in assignments) {
      if (assignment.id == id) return assignment;
    }
    return null;
  }
}
