import 'package:spring_calendario/core/l10n/app_language.dart';

enum SymptomType { cramps, headache, mood, bloating, acne, fatigue, appetite, sleep }

extension SymptomTypeLabel on SymptomType {
  String get label {
    switch (this) {
      case SymptomType.cramps:
        return AppLanguage.tr('Cólicos', 'Cramps');
      case SymptomType.headache:
        return AppLanguage.tr('Dolor de cabeza', 'Headache');
      case SymptomType.mood:
        return AppLanguage.tr('Cambios de humor', 'Mood changes');
      case SymptomType.bloating:
        return AppLanguage.tr('Hinchazón', 'Bloating');
      case SymptomType.acne:
        return AppLanguage.tr('Acné', 'Acne');
      case SymptomType.fatigue:
        return AppLanguage.tr('Fatiga', 'Fatigue');
      case SymptomType.appetite:
        return AppLanguage.tr('Cambios de apetito', 'Appetite changes');
      case SymptomType.sleep:
        return AppLanguage.tr('Problemas de sueño', 'Sleep problems');
    }
  }
}
