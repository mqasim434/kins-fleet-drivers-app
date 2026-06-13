import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/widgets/empty_state.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.moduleNumber,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final int moduleNumber;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: EmptyState(
        icon: icon,
        title: '$title komt binnenkort',
        subtitle: 'Module $moduleNumber wordt na test van de vorige module gebouwd.',
      ),
    );
  }
}
