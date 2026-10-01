/// Global constants used across the application.
class AppConstants {
  AppConstants._();

  static const String appName = 'LunaFlow';
  static const String tagline = 'Follow your cycle, moon by moon.';
  static const String disclaimer =
      'LunaFlow is an academic prototype. It does not provide medical advice or diagnosis.';

  // Cycle defaults (used until enough data has been logged).
  static const int defaultCycleLength = 28;
  static const int defaultPeriodDuration = 5;
  static const int lutealPhaseLength = 14;
  static const int fertileDaysBeforeOvulation = 5;
  static const int fertileDaysAfterOvulation = 1;

  // Cycles outside this range are ignored when computing averages.
  static const int minValidCycleLength = 18;
  static const int maxValidCycleLength = 60;

  // Demo data (the MVP has no backend).
  static const bool seedDemoData = true;
  static const String demoEmail = 'demo@lunaflow.app';
  static const String demoPassword = 'Luna1234';
}
