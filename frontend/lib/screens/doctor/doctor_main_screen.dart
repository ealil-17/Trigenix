import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';
import 'doctor_dashboard.dart';
import 'alerts_panel.dart';

class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({Key? key}) : super(key: key);

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    const DoctorDashboard(),
    const AlertsPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      body: GradientPageBackground(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveLayout.pageHorizontalPadding(context),
                8,
                ResponsiveLayout.pageHorizontalPadding(context),
                6,
              ),
              child: Row(
                children: [
                  Text('Doctor Portal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Toggle theme',
                    onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    icon: const Icon(Icons.contrast),
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                    onPressed: () => context.read<AuthProvider>().logout(),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (isTablet)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 10, bottom: 12),
                      child: NavigationRail(
                        selectedIndex: _currentIndex,
                        labelType: NavigationRailLabelType.all,
                        onDestinationSelected: (index) => setState(() => _currentIndex = index),
                        destinations: const [
                          NavigationRailDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: Text('Patients')),
                          NavigationRailDestination(icon: Icon(Icons.notification_important_outlined), selectedIcon: Icon(Icons.notification_important), label: Text('Alerts')),
                        ],
                      ),
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentIndex),
                        child: _screens[_currentIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Patients'),
                NavigationDestination(icon: Icon(Icons.notification_important_outlined), selectedIcon: Icon(Icons.notification_important), label: 'Alerts'),
              ],
            ),
    );
  }
}
