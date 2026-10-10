import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:kins_fleet_drivers/data/photo_quality.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  final _fleet = FleetRepository();
  late final Stream<FleetPhotoRound> _round = _fleet.watchFleetRound(todayIso());
  String _departmentId = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bussen')),
      body: StreamBuilder<FleetPhotoRound>(
        stream: _round,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Bussen laden is mislukt.'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final round = snapshot.data!;
          final counts = round.goodCounts();
          final visible = round.buses.where((bus) => bus.matchesDepartment(_departmentId)).toList();
          final completed = visible.where((bus) => (counts[bus.id] ?? 0) >= minFleetPhotos).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DropdownButtonFormField<String>(
                  value: _departmentId,
                  decoration: const InputDecoration(labelText: 'Afdeling'),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('Alle afdelingen')),
                    for (final department in round.departments)
                      DropdownMenuItem(value: department.id, child: Text(department.name)),
                  ],
                  onChanged: (value) => setState(() => _departmentId = value ?? 'all'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$completed/${visible.length} voltooid',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Minimaal 5 scherpe foto\'s vandaag. Iedereen ziet dezelfde stand.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('Geen bussen voor deze afdeling.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final bus = visible[index];
                          final count = counts[bus.id] ?? 0;
                          final done = count >= minFleetPhotos;
                          return _BusTile(bus: bus, count: count, done: done);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BusTile extends StatelessWidget {
  const _BusTile({required this.bus, required this.count, required this.done});

  final FleetBus bus;
  final int count;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xFF166534) : AppColors.muted;
    return Material(
      color: done ? const Color(0xFFE7F6EC) : const Color(0xFFF1EFED),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/buses/${bus.id}'),
        child: Opacity(
          opacity: done ? 1 : 0.72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.label,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color),
                      ),
                      if (bus.departmentNames.isNotEmpty)
                        Text(
                          bus.departmentNames.join(', '),
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      Text(
                        done ? '$count foto\'s' : '$count van $minFleetPhotos foto\'s',
                        style: TextStyle(color: color, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  done ? Icons.check_circle : Icons.photo_camera_outlined,
                  color: done ? const Color(0xFF15803D) : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
