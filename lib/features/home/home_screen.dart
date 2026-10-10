import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeData {
  const _HomeData({required this.shifts, required this.concessions, required this.concessionsFailed});

  final List<ShiftAssignment> shifts;
  final List<ConcessionRecord> concessions;
  final bool concessionsFailed;
}

class _HomeScreenState extends State<HomeScreen> {
  final _fleet = FleetRepository();
  late Future<_HomeData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_HomeData> _load() async {
    final session = context.read<AuthController>().session!;
    final shiftsFuture = _fleet.fetchShifts(session.driverRecord.id);
    final concessionsFuture = _fleet.fetchMyConcessions(
      transporterId: session.driverRecord.transporterId,
      driverName: session.driverRecord.fullName,
    );
    final shifts = await shiftsFuture;
    try {
      final concessions = await concessionsFuture;
      return _HomeData(shifts: shifts, concessions: concessions, concessionsFailed: false);
    } catch (_) {
      return _HomeData(shifts: shifts, concessions: const [], concessionsFailed: true);
    }
  }

  Future<void> _reload() async {
    setState(() => _data = _load());
    await _data;
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<AuthController>().session!.driverRecord;
    final today = todayIso();

    return Scaffold(
      appBar: AppBar(title: const Text('Vandaag')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<_HomeData>(
          future: _data,
          builder: (context, snapshot) {
            final todayShifts = (snapshot.data?.shifts ?? [])
                .where((shift) => shift.date == today)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hallo ${driver.displayName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  formatIsoDate(today),
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                _ConcessionsCard(data: snapshot.data),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  const _Card(
                    child: Text('Diensten laden is mislukt. Trek omlaag om opnieuw te proberen.'),
                  )
                else if (todayShifts.isEmpty)
                  const _Card(
                    child: Text('Geen dienst ingepland voor vandaag. Uw rooster komt uit de planning.'),
                  )
                else
                  ...todayShifts.map(
                    (shift) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Card(
                        onTap: () => context.push('/work/${shift.id}'),
                        child: _ShiftSummary(shift: shift),
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
}

class _ConcessionsCard extends StatelessWidget {
  const _ConcessionsCard({required this.data});

  final _HomeData? data;

  @override
  Widget build(BuildContext context) {
    final week = currentIsoWeek();
    if (data == null) return const SizedBox.shrink();
    if (data!.concessionsFailed) {
      return const _Card(
        child: Text('Concessies laden is mislukt. Trek omlaag om opnieuw te proberen.'),
      );
    }
    final items = data!.concessions;
    if (items.isEmpty) {
      return _Card(
        child: Text(
          'Geen concessies in week ${week.week}.',
          style: const TextStyle(color: AppColors.muted),
        ),
      );
    }
    return Material(
      color: const Color(0xFFFFF4F5),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.bordeaux),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Concessies deze week',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.bordeaux),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'U staat onder toezicht. Let op uw gedrag en laat geen pakketten achter.',
              style: TextStyle(height: 1.35),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  [
                    item.trackingId,
                    if (item.deliveryDate.isNotEmpty) formatIsoDate(item.deliveryDate),
                    if (item.comment.isNotEmpty) item.comment,
                  ].join(' · '),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShiftSummary extends StatelessWidget {
  const _ShiftSummary({required this.shift});
  final ShiftAssignment shift;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shift.shiftName.isEmpty ? 'Dienst' : shift.shiftName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        if (shift.timeLabel.isNotEmpty) Text(shift.timeLabel),
        if (shift.departmentName.isNotEmpty)
          Text(shift.departmentName, style: const TextStyle(color: AppColors.muted)),
        if (shift.vehicleLabel.isNotEmpty)
          Text(shift.vehicleLabel, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
