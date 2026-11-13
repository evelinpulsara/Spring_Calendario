import 'package:spring_calendario/core/l10n/app_language.dart';

/// How heavy the menstrual flow is on a given day.
enum FlowIntensity { none, light, medium, heavy }

extension FlowIntensityLabel on FlowIntensity {
  String get label {
    switch (this) {
      case FlowIntensity.none:
        return AppLanguage.tr('Ninguno', 'None');
      case FlowIntensity.light:
        return AppLanguage.tr('Ligero', 'Light');
      case FlowIntensity.medium:
        return AppLanguage.tr('Medio', 'Medium');
      case FlowIntensity.heavy:
        return AppLanguage.tr('Abundante', 'Heavy');
    }
  }
}
