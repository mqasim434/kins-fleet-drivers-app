import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:provider/provider.dart';

class DriverShell extends StatelessWidget {
  const DriverShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session;
    final fleetManager = session?.user.isFleetManager == true;
    final allowClock = session?.driver?.allowAppClock == true;
    final tabs = [
      '/home',
      '/work',
      '/vehicle',
      if (allowClock) '/clock',
      if (fleetManager) '/buses',
      '/account',
    ];
    final path = location;
    final index = tabs.indexWhere(
      (tab) => path == tab || path.startsWith('$tab/'),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        indicatorColor: AppColors.bordeaux.withValues(alpha: 0.12),
        onDestinationSelected: (selected) => context.go(tabs[selected]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Vandaag',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Diensten',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Voertuig',
          ),
          if (allowClock)
            const NavigationDestination(
              icon: Icon(Icons.access_time),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'Clock In',
            ),
          if (fleetManager)
            const NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus),
              label: 'Bussen',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
