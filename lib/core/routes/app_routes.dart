import 'package:flutter/material.dart';
import 'package:lunaflow/features/authentication/presentation/screens/auth_screen.dart';
import 'package:lunaflow/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:lunaflow/features/authentication/presentation/screens/splash_screen.dart';
import 'package:lunaflow/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:lunaflow/shared/widgets/main_shell.dart';

/// Named routes and the route generator.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String logSymptoms = '/log-symptoms';

  /// `auth` receives a bool argument: true to start in login mode.
  /// `logSymptoms` receives an optional [LogSymptomsArgs].
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
      case splash:
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
