import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._repository);

  final ShiftsRepository _repository;

  int todayShiftCount = 0;
  bool isLoading = false;
  bool hasError = false;

  Future<void> load(String driverId) async {
    if (driverId.isEmpty) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      todayShiftCount = await _repository.countTodayShifts(driverId);
    } on Exception catch (_) {
      hasError = true;
      todayShiftCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String driverId) => load(driverId);
}
