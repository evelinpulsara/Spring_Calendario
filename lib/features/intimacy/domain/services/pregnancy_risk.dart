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
