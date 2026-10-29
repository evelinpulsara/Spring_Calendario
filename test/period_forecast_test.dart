import 'package:flutter_test/flutter_test.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/cycle/data/services/local_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/data/services/remote_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/cycle/domain/services/period_forecast_service.dart';

void main() {
  const calculator = CycleCalculator();
  setUp(() => AppLanguage.isSpanish = true);

  List<PeriodEntry> days(DateTime start, int n) => [
        for (var i = 0; i < n; i++)
          PeriodEntry(
              id: '$start-$i',
              date: DateTime(start.year, start.month, start.day + i),
              flow: FlowIntensity.medium),
      ];

  ForecastInput inputFor(List<MenstrualCycle> cycles, DateTime today,
      {AgeGroup age = AgeGroup.adult,
      CycleRegularity reg = CycleRegularity.regular,
      int typicalPeriod = 5,
      int typicalCycle = 29}) {
    final baseline = calculator.predict(
      cycles: cycles,
      today: today,
      fallbackCycleLength: typicalCycle,
      fallbackPeriodLength: typicalPeriod,
    )!;
    return ForecastInput(
      today: today,
      ageGroup: age,
      regularity: reg,
      typicalPeriodLength: typicalPeriod,
      typicalCycleLength: typicalCycle,
      cycles: cycles,
      baseline: baseline,
    );
  }

  test('ejemplo real: periodo el 22 oct, ciclo de 29 días -> 20 nov, ovulación 6 nov', () async {
    final cycles = calculator.buildCycles(days(DateTime(2026, 10, 22), 5));
    final input = inputFor(cycles, DateTime(2026, 11, 13));
    final f = await const LocalPeriodForecastService().forecast(input);

    expect(f.likelyStart, DateTime(2026, 11, 20));
    expect(f.ovulationDate, DateTime(2026, 11, 6));
    expect(f.periodLength, 5);
    // Pocos datos: ventana de 2 días a cada lado.
    expect(f.earliestStart, DateTime(2026, 11, 18));
    expect(f.latestStart, DateTime(2026, 11, 22));
    expect(f.isFromAi, isFalse);
  });

  test('ciclo irregular o adolescente -> ventana más ancha', () {
    final cycles = calculator.buildCycles(days(DateTime(2026, 10, 22), 5));
    final today = DateTime(2026, 11, 13);
    final regular = LocalPeriodForecastService.windowSide(inputFor(cycles, today));
    final irregularTeen = LocalPeriodForecastService.windowSide(
        inputFor(cycles, today, age: AgeGroup.teen, reg: CycleRegularity.irregular));
    expect(irregularTeen, greaterThan(regular));
    expect(irregularTeen, lessThanOrEqualTo(4));
  });

  test('un periodo recién empezado no acorta la duración esperada', () {
    // Empezó hace 1 día (solo 2 días registrados) y suele durar 6.
    final cycles = calculator.buildCycles(days(DateTime(2026, 11, 12), 2));
    final input = inputFor(cycles, DateTime(2026, 11, 13), typicalPeriod: 6);
    expect(input.expectedPeriodLength, 6);
  });

  test('con la predicción: días de posible inicio y días opacos del periodo actual', () {
    // Registró solo el primer día; la predicción dice que dura 5.
    final cycles = calculator.buildCycles(days(DateTime(2026, 11, 13), 1));
    final projection = calculator.project(
      cycles: cycles,
      fallbackCycleLength: 29,
      fallbackPeriodLength: 5,
      override: PredictionOverride(
        earliestStart: DateTime(2026, 12, 10),
        likelyStart: DateTime(2026, 12, 11),
        latestStart: DateTime(2026, 12, 12),
        periodLength: 5,
        ovulationDate: DateTime(2026, 11, 27),
      ),
    );
    expect(projection.possibleStartDays,
        {DateTime(2026, 12, 10), DateTime(2026, 12, 11), DateTime(2026, 12, 12)});
    expect(projection.expectedPeriodDays, {
      DateTime(2026, 11, 14),
      DateTime(2026, 11, 15),
      DateTime(2026, 11, 16),
      DateTime(2026, 11, 17),
    });
    expect(projection.ovulationDays, contains(DateTime(2026, 11, 27)));
    expect(projection.predictedPeriodDays, contains(DateTime(2026, 12, 11)));
    expect(projection.predictedPeriodDays, contains(DateTime(2026, 12, 15)));
  });

  test('datos enviados a la IA (sin nombre ni correo)', () {
    final cycles = calculator.buildCycles(days(DateTime(2026, 10, 22), 5));
    final body = RemotePeriodForecastService.buildRequestBody(
        inputFor(cycles, DateTime(2026, 11, 13), age: AgeGroup.teen));
    expect(body['today'], '2026-11-13');
    expect(body['profile'], {
      'ageGroup': 'teen',
      'regularity': 'regular',
      'typicalPeriodLength': 5,
      'typicalCycleLength': 29,
    });
    expect(body['cycles'], [
      {'startDate': '2026-10-22', 'periodLength': 5, 'cycleLength': null}
    ]);
    expect(body['baseline'],
        {'nextStart': '2026-11-20', 'periodLength': 5, 'ovulation': '2026-11-06'});
    expect(body.toString(), isNot(contains('@')));
  });
}
