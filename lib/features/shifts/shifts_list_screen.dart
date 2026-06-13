import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_provider.dart';
import 'package:kins_fleet_drivers/features/shifts/widgets/shift_list_tile.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/widgets/empty_state.dart';
import 'package:kins_fleet_drivers/widgets/error_banner.dart';
import 'package:kins_fleet_drivers/widgets/loading_overlay.dart';

class ShiftsListScreen extends StatefulWidget {
  const ShiftsListScreen({super.key});

  @override
  State<ShiftsListScreen> createState() => _ShiftsListScreenState();
}

class _ShiftsListScreenState extends State<ShiftsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final driverId = context.read<AuthProvider>().user?.driverId ?? '';
    await context.read<ShiftsProvider>().load(driverId);
  }

  Future<void> _refresh() async {
    final driverId = context.read<AuthProvider>().user?.driverId ?? '';
    await context.read<ShiftsProvider>().refresh(driverId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shifts = context.watch<ShiftsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shiftsTitle),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.accent,
            child: _buildBody(l10n, shifts),
          ),
          if (shifts.isLoading && shifts.assignments.isEmpty)
            LoadingOverlay(message: l10n.shiftsLoading),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ShiftsProvider shifts) {
    if (!shifts.isLoading && !shifts.hasError && shifts.assignments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          EmptyState(
            icon: Icons.event_busy_outlined,
            title: l10n.shiftsEmpty,
            subtitle: l10n.shiftsEmptySubtitle,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (shifts.hasError) ...[
          ErrorBanner(message: l10n.errorLoadShifts),
          const SizedBox(height: 16),
        ],
        Text(
          l10n.shiftsUpcoming,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        ...shifts.assignments.map(
          (assignment) => ShiftListTile(assignment: assignment),
        ),
      ],
    );
  }
}
