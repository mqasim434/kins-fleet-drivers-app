import 'package:flutter/material.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';

/// Branded splash shown while auth initializes. Matches native launch screen
/// (surface background + logo) for a seamless handoff from OS splash.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _logoAsset = 'assets/branding/app_logo.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _logoAsset,
                  width: 120,
                  height: 120,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.local_shipping_outlined,
                    size: 72,
                    color: AppColors.bordeaux.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'KINS Chauffeur',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.bordeaux,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.bordeaux,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
