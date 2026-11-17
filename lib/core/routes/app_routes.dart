import 'package:flutter/material.dart';
import 'package:spring_calendario/features/authentication/presentation/screens/auth_screen.dart';
import 'package:spring_calendario/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:spring_calendario/features/authentication/presentation/screens/splash_screen.dart';
import 'package:spring_calendario/features/cycle/presentation/screens/cycle_setup_screen.dart';
import 'package:spring_calendario/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String logSymptoms = '/log-symptoms';
  static const String cycleSetup = '/cycle-setup';

  static String afterLogin(bool cycleSetupCompleted) => cycleSetupCompleted ? home : cycleSetup;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case onboarding:
        page = const OnboardingScreen();
        break;
      case auth:
        page = AuthScreen(startInLoginMode: settings.arguments as bool? ?? false);
        break;
      case home:
        page = const MainShell();
        break;
      case logSymptoms:
        final args = settings.arguments as LogSymptomsArgs?;
        page = LogSymptomsScreen(
          isStandalone: true,
          initialDate: args?.initialDate,
          preselected: args?.preselected,
        );
        break;
      case cycleSetup:
        page = CycleSetupScreen(isEditing: settings.arguments as bool? ?? false);
        break;
      case splash:
      default:
        page = const SplashScreen();
    }
    return SoftPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
