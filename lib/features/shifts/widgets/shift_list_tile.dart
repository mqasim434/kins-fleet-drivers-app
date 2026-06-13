import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/widgets/shift_status_badge.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/routing/routes.dart';
import 'package:provider/provider.dart';

class ShiftListTile extends StatelessWidget {
  const ShiftListTile({super.key, required this.assignment});

  final ShiftAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = context.watch<LocaleProvider>().dateLocaleTag;
    final parsedDate = DateTime.tryParse('${assignment.date}T00:00:00');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.shiftDetail(assignment.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.shiftName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ShiftStatusBadge(status: assignment.status),
                ],
              ),
              const SizedBox(height: 8),
              if (parsedDate != null)
                Text(
                  AppDateUtils.formatShortDate(parsedDate, localeTag),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 8),
              _InfoLine(
                icon: Icons.schedule,
                text: '${assignment.startTime} – ${assignment.endTime}',
              ),
              _InfoLine(
                icon: Icons.directions_bus_outlined,
                text: l10n.busLine(
                  assignment.busNumber,
                  assignment.licensePlate,
                ),
              ),
              _InfoLine(
                icon: Icons.business_outlined,
                text: assignment.departmentName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
