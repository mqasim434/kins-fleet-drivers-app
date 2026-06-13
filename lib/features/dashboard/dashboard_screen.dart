import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/dashboard/dashboard_provider.dart';
import 'package:kins_fleet_drivers/features/dashboard/widgets/kpi_card.dart';
import 'package:kins_fleet_drivers/features/dashboard/widgets/quick_links_grid.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/routing/routes.dart';
import 'package:kins_fleet_drivers/widgets/error_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final driverId = auth.user?.driverId;
    if (driverId != null && driverId.isNotEmpty) {
      await context.read<DashboardProvider>().load(driverId);
    }
  }

  Future<void> _refresh() async {
    final driverId = context.read<AuthProvider>().user?.driverId ?? '';
    await context.read<DashboardProvider>().refresh(driverId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final today = AppDateUtils.formatDate(
      DateTime.now(),
      localeProvider.dateLocaleTag,
    );

    final quickLinks = [
      QuickLink(
        label: l10n.quickMyShifts,
        icon: Icons.calendar_today_outlined,
        route: AppRoutes.shifts,
        color: AppColors.accent,
      ),
      QuickLink(
        label: l10n.quickPhotos,
        icon: Icons.photo_camera_outlined,
        route: AppRoutes.photos,
        color: const Color(0xFF7C3AED),
      ),
      QuickLink(
        label: l10n.quickHandover,
        icon: Icons.swap_horiz_outlined,
        route: AppRoutes.handovers,
        color: const Color(0xFF0891B2),
      ),
      QuickLink(
        label: l10n.quickDamage,
        icon: Icons.report_outlined,
        route: AppRoutes.damage,
        color: AppColors.error,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.dashboardHello(auth.driverDisplayName),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              today,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            if (dashboard.hasError) ...[
              ErrorBanner(message: l10n.errorLoadDashboard),
              const SizedBox(height: 16),
            ],
            KpiCard(
              label: l10n.dashboardShiftsToday,
              value: '${dashboard.todayShiftCount}',
              icon: Icons.directions_bus_outlined,
              isLoading: dashboard.isLoading,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dashboardQuickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            QuickLinksGrid(links: quickLinks),
          ],
        ),
      ),
    );
  }
}
