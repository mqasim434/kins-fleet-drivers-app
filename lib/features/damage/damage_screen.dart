import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/utils/dates.dart';
import 'package:kins_fleet_drivers/data/fleet_repository.dart';
import 'package:kins_fleet_drivers/data/models.dart';
import 'package:provider/provider.dart';

class DamageScreen extends StatefulWidget {
  const DamageScreen({super.key});

  @override
  State<DamageScreen> createState() => _DamageScreenState();
}

class _DamageScreenState extends State<DamageScreen> {
  final _fleet = FleetRepository();
  late Future<List<DamageReport>> _reports;

  @override
  void initState() {
    super.initState();
    _reports = _load();
  }

  Future<List<DamageReport>> _load() {
    final uid = context.read<AuthController>().session!.user.uid;
    return _fleet.fetchMyDamage(uid);
  }

  Future<void> _reload() async {
    setState(() => _reports = _load());
    await _reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schade')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.bordeaux,
        foregroundColor: Colors.white,
        onPressed: () async {
          final saved = await context.push<bool>('/photos/new?purpose=damage');
          if (saved == true) _reload();
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Melden'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<DamageReport>>(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text('Nog geen schademeldingen. Een melding met foto komt bij de wagenparkbeheerder in Schades terecht.'),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final report = reports[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(
                      [report.busNumber, report.licensePlate].where((part) => part.isNotEmpty).join(' · '),
                    ),
                    subtitle: Text(
                      '${_typeLabel(report.damageType)} · ${_statusLabel(report.status)}\n${formatIsoDate(report.date)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'dent':
        return 'Deuk';
      case 'scratch':
        return 'Kras';
      case 'paint_damage':
        return 'Lakschade';
      case 'bumper_damage':
        return 'Bumper';
      case 'broken_mirror':
        return 'Spiegel';
      default:
        return 'Overig';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Bevestigd';
      case 'rejected':
        return 'Afgewezen';
      case 'repaired':
        return 'Gerepareerd';
      default:
        return 'Gemeld';
    }
  }
}
