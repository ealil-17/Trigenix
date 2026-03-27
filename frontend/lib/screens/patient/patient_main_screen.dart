import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';
import 'patient_dashboard.dart';
import 'ecg_input_screen.dart';
import 'history_screen.dart';

class PatientMainScreen extends StatefulWidget {
  const PatientMainScreen({Key? key}) : super(key: key);

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    const PatientDashboard(),
    const EcgInputScreen(),
    const HistoryScreen(),
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
                  Text('Patient Portal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
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
                          NavigationRailDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard_customize), label: Text('Home')),
                          NavigationRailDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: Text('Analyze')),
                          NavigationRailDestination(icon: Icon(Icons.history_toggle_off), selectedIcon: Icon(Icons.history), label: Text('History')),
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
                NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard_customize), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'Analyze'),
                NavigationDestination(icon: Icon(Icons.history_toggle_off), selectedIcon: Icon(Icons.history), label: 'History'),
              ],
            ),
    );
  }
}
