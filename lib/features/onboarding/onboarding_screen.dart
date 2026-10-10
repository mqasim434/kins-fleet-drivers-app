import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/features/onboarding/onboarding_repository.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _repo = OnboardingRepository();
  late Future<List<OnboardingCandidate>> _items;

  @override
  void initState() {
    super.initState();
    _items = _repo.fetchOpen();
  }

  Future<void> _reload() async {
    setState(() => _items = _repo.fetchOpen());
    await _items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthController>().signOut(),
            child: const Text('Uitloggen'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.bordeaux,
        foregroundColor: Colors.white,
        onPressed: () async {
          final saved = await context.push<bool>('/onboard/new');
          if (saved == true) _reload();
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nieuwe chauffeur'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<OnboardingCandidate>>(
          future: _items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Onboarding laden is mislukt.'),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? const <OnboardingCandidate>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                const Text(
                  'Maak hier het chauffeursdossier en fotografeer de documenten. Op het dashboard gaat de onboarding verder bij de ontbrekende stappen.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Text('Nog geen open onboarding.')
                else
                  for (final item in items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.fullName.isEmpty ? item.email : item.fullName),
                        subtitle: Text(
                          '${item.location.isEmpty ? 'Locatie onbekend' : item.location} · ${item.uploadedRequired} van ${progressDocKeys.length} documenten',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final saved = await context.push<bool>('/onboard/${item.id}');
                          if (saved == true) _reload();
                        },
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
