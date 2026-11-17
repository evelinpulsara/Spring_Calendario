import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/screens/calendar_screen.dart';
import 'package:spring_calendario/features/cycle/presentation/screens/insights_screen.dart';
import 'package:spring_calendario/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/profile/presentation/screens/profile_screen.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/sidebar.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  bool? _menuExpanded;
  late final Future<List<void>> _loading;

  @override
  void initState() {
    super.initState();
    _loading = Future.wait<void>([
      context.read<CycleController>().load(),
      context.read<SymptomController>().load(),
      context.read<IntimacyController>().load(),
    ]);
  }

  List<Destination> _destinations(AppLocalizations t) => [
        Destination(Icons.home_outlined, Icons.home_rounded, t.dashboard),
        Destination(Icons.calendar_month_outlined, Icons.calendar_month_rounded, t.calendar),
        Destination(Icons.add_circle_outline, Icons.add_circle_rounded, t.logSymptomsTitle),
        Destination(Icons.insights_outlined, Icons.insights_rounded, t.insights),
        Destination(Icons.person_outline, Icons.person_rounded, t.profile),
      ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<List<void>>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final pages = FadeIndexedStack(
          index: _index,
          children: const [
            DashboardScreen(),
            CalendarScreen(),
            LogSymptomsScreen(),
            InsightsScreen(),
            ProfileScreen(),
          ],
        );
        final destinations = _destinations(t);
        final width = MediaQuery.sizeOf(context).width;

        if (width < Breakpoints.wide) {
          return Scaffold(
            body: pages,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              Sidebar(
                destinations: destinations,
                selectedIndex: _index,
                onSelected: _select,
                expanded: _menuExpanded ?? width >= Breakpoints.extendedMenu,
                onToggle: () => setState(
                  () => _menuExpanded = !(_menuExpanded ?? width >= Breakpoints.extendedMenu),
                ),
              ),
              Expanded(child: pages),
            ],
          ),
        );
      },
    );
  }
}

class Destination {
  const Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
