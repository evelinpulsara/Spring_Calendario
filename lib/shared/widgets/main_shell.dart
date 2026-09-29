import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/cycle/presentation/screens/calendar_screen.dart';
import 'package:lunaflow/features/cycle/presentation/screens/insights_screen.dart';
import 'package:lunaflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lunaflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/screens/log_symptoms_screen.dart';

/// Hosts the five main tabs and the bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final Future<List<void>> _loading;

  @override
  void initState() {
    super.initState();
    _loading = Future.wait<void>([
      context.read<CycleController>().load(),
      context.read<SymptomController>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<void>>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: const [
              DashboardScreen(),
              CalendarScreen(),
              LogSymptomsScreen(),
              InsightsScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar'),
              NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: 'Log'),
              NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Insights'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
