import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';

/// Nivel de riesgo de embarazo ESTIMADO (no es un diagnóstico).
enum PregnancyRisk { low, moderate, high }

/// Resultado del análisis de una relación registrada.
class IntimacyRiskInfo {
  const IntimacyRiskInfo({
    required this.entry,
    required this.risk,
    required this.inFertileWindow,
    required this.isOvulationDay,
    required this.daysAgo,
  });

  final IntimacyEntry entry;
  final PregnancyRisk risk;
  final bool inFertileWindow;
  final bool isOvulationDay;

  /// Días que pasaron desde la relación (0 = hoy).
  final int daysAgo;

  /// La pastilla de emergencia puede usarse hasta 5 días (120 h) después,
  /// y es más eficaz cuanto antes se tome.
  bool get withinEmergencyWindow => daysAgo >= 0 && daysAgo <= 5;

  /// Riesgo alto y aún a tiempo de la anticoncepción de emergencia.
  bool get needsAttention => risk == PregnancyRisk.high && withinEmergencyWindow;
}

/// Reglas simples y conocidas para estimar el riesgo:
///  * Sin protección (o sin saber) en la ventana fértil -> riesgo alto.
///  * Con protección en la ventana fértil -> riesgo moderado (los métodos pueden fallar).
///  * Fuera de la ventana fértil -> riesgo bajo (no es cero: los ciclos varían).
class PregnancyRiskCalculator {
  const PregnancyRiskCalculator();

  IntimacyRiskInfo assess(IntimacyEntry entry, CycleProjection projection, DateTime today) {
    final day = AppDateUtils.dateOnly(entry.date);
    final fertile = projection.fertileDays.contains(day);
    final ovulation = projection.ovulationDays.contains(day);

    final PregnancyRisk risk;
    if (fertile || ovulation) {
      risk = entry.protection.isUnprotected ? PregnancyRisk.high : PregnancyRisk.moderate;
    } else {
      risk = PregnancyRisk.low;
    }

    return IntimacyRiskInfo(
      entry: entry,
      risk: risk,
      inFertileWindow: fertile || ovulation,
      isOvulationDay: ovulation,
      daysAgo: AppDateUtils.daysBetween(day, AppDateUtils.dateOnly(today)),
    );
  }
}
