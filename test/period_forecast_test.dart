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
