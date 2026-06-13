import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';

class ShiftsProvider extends ChangeNotifier {
  ShiftsProvider(this._repository);

  final ShiftsRepository _repository;

  List<ShiftAssignment> assignments = [];
  bool isLoading = false;
  bool hasError = false;

  Future<void> load(String driverId) async {
    if (driverId.isEmpty) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      assignments = await _repository.fetchUpcomingShifts(driverId);
    } on Exception catch (_) {
      hasError = true;
      assignments = [];
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
