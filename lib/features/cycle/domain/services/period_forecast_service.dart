import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';

/// Datos para predecir el próximo periodo.
class ForecastInput {
  const ForecastInput({
    required this.today,
    required this.ageGroup,
    required this.regularity,
    required this.typicalPeriodLength,
    required this.typicalCycleLength,
    required this.cycles,
    required this.baseline,
  });

  final DateTime today;
  final AgeGroup ageGroup;
  final CycleRegularity regularity;
  final int typicalPeriodLength;
  final int typicalCycleLength;
  final List<MenstrualCycle> cycles;

  /// Cálculo simple por promedios (referencia y respaldo).
  final CyclePrediction baseline;

