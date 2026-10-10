import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:provider/provider.dart';

class ShiftDetailScreen extends StatelessWidget {
  const ShiftDetailScreen({super.key, required this.shiftId});

  final String shiftId;

  @override
  Widget build(BuildContext context) {
    final driverId = context.read<AuthController>().session!.driverRecord.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Dienst')),
      body: FutureBuilder<List<ShiftAssignment>>(
        future: FleetRepository().fetchShifts(driverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final shift = snapshot.data?.where((item) => item.id == shiftId).firstOrNull;
          if (shift == null) {
            return const Center(child: Text('Deze dienst is niet gevonden.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                shift.shiftName.isEmpty ? 'Dienst' : shift.shiftName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(formatIsoDate(shift.date), style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              _Row(label: 'Tijd', value: shift.timeLabel),
              _Row(label: 'Afdeling', value: shift.departmentName),
              _Row(label: 'Bus', value: shift.busNumber),
              _Row(label: 'Kenteken', value: shift.licensePlate),
              _Row(label: 'Route', value: shift.routeCode),
              _Row(label: 'Locatie', value: shift.locationCode),
              _Row(label: 'Opmerking', value: shift.notes),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
