import 'package:spring_calendario/core/l10n/app_language.dart';

/// The four simplified phases of the menstrual cycle.
enum CyclePhase { menstrual, follicular, ovulation, luteal }

extension CyclePhaseInfo on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstrual:
        return AppLanguage.tr('Fase menstrual', 'Menstrual phase');
      case CyclePhase.follicular:
        return AppLanguage.tr('Fase folicular', 'Follicular phase');
      case CyclePhase.ovulation:
        return AppLanguage.tr('Fase de ovulación', 'Ovulation phase');
      case CyclePhase.luteal:
        return AppLanguage.tr('Fase lútea', 'Luteal phase');
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return AppLanguage.tr(
            'Buen momento para descansar, hidratarte y ser amable contigo misma.',
            'A good time to rest, hydrate and be gentle with yourself.');
      case CyclePhase.follicular:
        return AppLanguage.tr(
            'La energía suele aumentar. Ideal para planificar y nuevas rutinas.',
            'Energy often rises in this phase. Great for planning and new routines.');
      case CyclePhase.ovulation:
        return AppLanguage.tr(
            'Pico fértil estimado de tu ciclo.', 'Estimated fertile peak of your cycle.');
      case CyclePhase.luteal:
        return AppLanguage.tr(
            'Algunos síntomas premenstruales pueden aparecer. Registra cómo te sientes.',
            'Some people notice premenstrual symptoms. Track how you feel.');
    }
  }
}
