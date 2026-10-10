import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:provider/provider.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _fleet = FleetRepository();
  late Future<List<FleetBus>> _buses;

  @override
  void initState() {
    super.initState();
    _buses = _load();
  }

  Future<List<FleetBus>> _load() async {
    final driverId = context.read<AuthController>().session!.driverRecord.id;
    final today = todayIso();
    final shifts = await _fleet.fetchShifts(driverId);
    final todayBuses = <String, FleetBus>{};
    for (final shift in shifts.where((item) => item.date == today && item.busId.isNotEmpty)) {
      todayBuses.putIfAbsent(shift.busId, () => FleetBus.fromShift(shift));
    }
    final detailed = <FleetBus>[];
    for (final bus in todayBuses.values) {
      detailed.add(await _fleet.fetchBus(bus.id) ?? bus);
    }
    return detailed;
  }

  Future<void> _reload() async {
    setState(() => _buses = _load());
    await _buses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voertuig')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<FleetBus>>(
          future: _buses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final buses = snapshot.data ?? [];
            if (buses.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text('Geen voertuig ingepland voor vandaag. De bus komt uit uw dienst in de planning.'),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final bus in buses)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bus.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          if (bus.licensePlate.isNotEmpty)
                            Text(bus.licensePlate, style: const TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 12),
                          if (bus.brand.isNotEmpty || bus.model.isNotEmpty)
                            Text('${bus.brand} ${bus.model}'.trim()),
                          if (bus.status.isNotEmpty)
                            Text('Status: ${_statusLabel(bus.status)}'),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Beschikbaar';
      case 'maintenance':
        return 'Onderhoud';
      case 'inactive':
        return 'Inactief';
      default:
        return status;
    }
  }
}
