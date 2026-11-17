import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';

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

  final CyclePrediction baseline;

  int get expectedPeriodLength {
    final finished = [
      for (var i = 0; i < cycles.length; i++)
        if (i < cycles.length - 1 ||
            AppDateUtils.daysBetween(cycles[i].startDate, today) >= typicalPeriodLength)
          cycles[i].periodLength,
    ];
    if (finished.isEmpty) return typicalPeriodLength;
    return (finished.reduce((a, b) => a + b) / finished.length).round();
  }

  String get cacheKey => [
        today.toIso8601String(),
        ageGroup.name,
        regularity.name,
        typicalPeriodLength,
        typicalCycleLength,
        for (final c in cycles) '${c.startDate.toIso8601String()}/${c.periodLength}/${c.cycleLength}',
      ].join('|');
}

abstract class PeriodForecastService {
  Future<PeriodForecast> forecast(ForecastInput input);
}
