import 'package:spring_calendario/core/l10n/app_language.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Spring';
  static String get tagline =>
      AppLanguage.tr('Sigue tu ciclo, día a día.', 'Follow your cycle, day by day.');
  static String get disclaimer => AppLanguage.tr(
      'Spring es un prototipo académico. No ofrece consejos ni diagnósticos médicos.',
      'Spring is an academic prototype. It does not provide medical advice or diagnosis.');

  static const int defaultCycleLength = 28;
  static const int defaultPeriodDuration = 5;
  static const int lutealPhaseLength = 14;
  static const int fertileDaysBeforeOvulation = 5;
  static const int fertileDaysAfterOvulation = 1;

  static const int minValidCycleLength = 18;
  static const int maxValidCycleLength = 60;

  static const bool seedDemoData = true;
  static const String demoEmail = 'demo@spring.app';
  static const String demoPassword = 'Spring1234';
}
