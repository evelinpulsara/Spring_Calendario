import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';

/// Textos de orientación sobre el riesgo de embarazo (información general,
/// no reemplaza la consulta con un profesional de salud).
class PregnancyGuidance {
  PregnancyGuidance._();

  static String when(int daysAgo) {
    if (daysAgo <= 0) return AppLanguage.tr('hoy', 'today');
    if (daysAgo == 1) return AppLanguage.tr('ayer', 'yesterday');
    return AppLanguage.tr('hace $daysAgo días', '$daysAgo days ago');
  }

  static String title(IntimacyRiskInfo info) {
    switch (info.risk) {
      case PregnancyRisk.high:
        return AppLanguage.tr('Posible riesgo de embarazo', 'Possible pregnancy risk');
      case PregnancyRisk.moderate:
        return AppLanguage.tr('Riesgo bajo, pero atenta', 'Low risk, but stay alert');
      case PregnancyRisk.low:
        return AppLanguage.tr('Riesgo de embarazo bajo', 'Low pregnancy risk');
    }
  }

  static String message(IntimacyRiskInfo info) {
    final when = PregnancyGuidance.when(info.daysAgo);
    final day = info.isOvulationDay
        ? AppLanguage.tr('en tu día de ovulación estimado', 'on your estimated ovulation day')
        : AppLanguage.tr('durante tu ventana fértil estimada', 'during your estimated fertile window');

    switch (info.risk) {
      case PregnancyRisk.high:
        if (info.withinEmergencyWindow) {
          return AppLanguage.tr(
            'Registraste una relación sin protección $when $day. Si no buscas un embarazo, '
                'puedes considerar la pastilla anticonceptiva de emergencia: es más eficaz cuanto antes '
                'se tome (idealmente en las primeras 72 horas, y algunas opciones funcionan hasta 5 días). '
                'Puedes pedirla en una farmacia o centro de salud. Si tu menstruación se retrasa más de '
                'una semana, hazte una prueba de embarazo.',
            'You logged unprotected sex $when $day. If you are not trying to get pregnant, you can '
                'consider the emergency contraceptive pill: it works best the sooner it is taken '
                '(ideally within 72 hours, and some options work up to 5 days). You can get it at a '
                'pharmacy or health center. If your period is more than a week late, take a pregnancy test.',
          );
        }
        return AppLanguage.tr(
          'Registraste una relación sin protección $when $day. Ya pasaron más de 5 días, así que la '
              'pastilla de emergencia podría no ser eficaz. Si tu menstruación se retrasa, hazte una '
              'prueba de embarazo y consulta a un profesional de salud.',
          'You logged unprotected sex $when $day. More than 5 days have passed, so the emergency pill '
              'may no longer work. If your period is late, take a pregnancy test and talk to a health professional.',
