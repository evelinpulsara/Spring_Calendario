import 'dart:math' as math;

import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';
import 'package:spring_calendario/features/cycle/domain/services/period_forecast_service.dart';

/// Predicción local (sin internet): promedio de ciclos + una ventana de días
/// más ancha cuando el ciclo es irregular, adolescente o hay pocos datos.
class LocalPeriodForecastService implements PeriodForecastService {
  const LocalPeriodForecastService();

  @override
  Future<PeriodForecast> forecast(ForecastInput input) async {
    final baseline = input.baseline;
    final likely = baseline.nextPeriodStart;
    final side = windowSide(input);
    final complete = input.cycles.where((c) => c.cycleLength != null).length;

    final confidence = side <= 1 && complete >= 3
        ? 'high'
        : side >= 3
            ? 'low'
            : 'medium';

    return PeriodForecast(
      earliestStart: AppDateUtils.addDays(likely, -side),
      likelyStart: likely,
      latestStart: AppDateUtils.addDays(likely, side),
      periodLength: input.expectedPeriodLength,
      ovulationDate: AppDateUtils.addDays(likely, -14),
      confidence: confidence,
      explanation: AppLanguage.tr(
        'Cálculo según el promedio de tus ciclos y tus respuestas. Es una estimación.',
        'Calculated from your cycle average and your answers. This is an estimate.',
      ),
    );
  }

  /// Días antes/después del día más probable.
  static int windowSide(ForecastInput input) {
    final lengths = input.cycles.map((c) => c.cycleLength).whereType<int>().toList();
    var side = 1;
    if (lengths.length < 3) side = 2;
    if (lengths.length >= 2) {
      final spread = lengths.reduce(math.max) - lengths.reduce(math.min);
      if (spread > 4) side = 3;
    }
    if (input.regularity == CycleRegularity.irregular) side = math.max(side, 3);
    if (input.regularity == CycleRegularity.unsure) side = math.max(side, 2);
    if (input.ageGroup == AgeGroup.teen) side += 1;
    return side.clamp(1, 4);
  }
}
