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
