import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:kins_fleet_drivers/features/work/time_off_request.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final _fleet = FleetRepository();
  late Future<List<ShiftAssignment>> _shifts;
  late Future<List<TimeOffRequest>> _requests;

  @override
  void initState() {
    super.initState();
    _shifts = _load();
    _requests = _loadRequests();
  }

  Future<List<ShiftAssignment>> _load() {
    final driverId = context.read<AuthController>().session!.driverRecord.id;
    return _fleet.fetchShifts(driverId);
  }

  Future<List<TimeOffRequest>> _loadRequests() {
    final driverId = context.read<AuthController>().session!.driverRecord.id;
    return loadMyTimeOff(driverId);
  }

  Future<void> _reload() async {
    setState(() {
      _shifts = _load();
      _requests = _loadRequests();
    });
    await Future.wait([_shifts, _requests]);
  }

  Future<void> _requestTimeOff() async {
    final saved = await showTimeOffRequest(context);
    if (saved) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final today = todayIso();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diensten'),
        actions: [
          TextButton(
            onPressed: _requestTimeOff,
            child: const Text('Verlof'),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<List<TimeOffRequest>>(
            future: _requests,
            builder: (context, snapshot) {
              return TimeOffRequestBanner(requests: snapshot.data ?? const []);
            },
          ),
          Expanded(
            child: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<ShiftAssignment>>(
          future: _shifts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Diensten laden is mislukt.'),
                  ),
                ],
              );
            }
            final upcoming = (snapshot.data ?? [])
                .where((shift) => shift.date.compareTo(today) >= 0)
                .toList();
            if (upcoming.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Geen komende diensten. Het rooster wordt in de planning bijgehouden.'),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final shift = upcoming[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(shift.shiftName.isEmpty ? 'Dienst' : shift.shiftName),
                    subtitle: Text(
                      [
                        formatIsoDate(shift.date),
                        shift.timeLabel,
                        shift.vehicleLabel,
                      ].where((part) => part.isNotEmpty).join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                    onTap: () => context.push('/work/${shift.id}'),
                  ),
                );
              },
            );
          },
        ),
            ),
          ),
        ],
      ),
    );
  }
}
