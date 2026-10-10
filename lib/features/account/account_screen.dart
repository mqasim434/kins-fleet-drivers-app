import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session!;
    final driver = session.driverRecord;
    final user = session.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            driver.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            user.isFleetManager ? 'Chauffeur · wagenparkbeheerder' : 'Chauffeur',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gegevens komen uit het chauffeursdossier. Wijzigingen doet de planning.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          _Info(label: 'E-mail', value: user.email),
          _Info(label: 'Telefoon', value: driver.phone),
          _Info(label: 'Personeelsnummer', value: driver.employeeId),
          _Info(label: 'Transporter ID', value: driver.transporterId),
          _Info(label: 'Afdeling', value: driver.departmentName),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.read<AuthController>().signOut(),
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
