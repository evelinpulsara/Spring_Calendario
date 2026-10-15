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
