import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';

class ShiftStatusBadge extends StatelessWidget {
  const ShiftStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (background, foreground) = _colorsForStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.shiftStatus(status),
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colorsForStatus(String status) {
    return switch (status) {
      'completed' => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
        ),
      'cancelled' => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
        ),
      _ => (
          AppColors.accent.withValues(alpha: 0.12),
          AppColors.accent,
        ),
    };
  }
}
