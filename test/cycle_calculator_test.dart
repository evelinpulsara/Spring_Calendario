import 'package:flutter_test/flutter_test.dart';
import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';
import 'package:lunaflow/features/cycle/domain/entities/period_entry.dart';
import 'package:lunaflow/features/cycle/domain/services/cycle_calculator.dart';

PeriodEntry _day(DateTime date) =>
    PeriodEntry(id: date.toIso8601String(), date: date, flow: FlowIntensity.medium);

void main() {
  const calculator = CycleCalculator();

  final entries = [
    DateTime(2026, 1, 1),
    DateTime(2026, 1, 2),
    DateTime(2026, 1, 3),
    DateTime(2026, 1, 29),
    DateTime(2026, 1, 30),
  ].map(_day).toList();

  test('groups consecutive period days into cycles', () {
    final cycles = calculator.buildCycles(entries);
    expect(cycles.length, 2);
    expect(cycles.first.periodLength, 3);
    expect(cycles.first.cycleLength, 28);
    expect(cycles.last.isInProgress, isTrue);
  });

  test('calculates averages', () {
    final cycles = calculator.buildCycles(entries);
    expect(calculator.averageCycleLength(cycles), 28);
    expect(calculator.averagePeriodLength(cycles), 2.5);
  });

  test('predicts the next period and cycle day', () {
    final cycles = calculator.buildCycles(entries);
    final prediction = calculator.predict(
      cycles: cycles,
      today: DateTime(2026, 2, 5),
      fallbackCycleLength: 28,
      fallbackPeriodLength: 5,
    )!;
    expect(prediction.cycleDay, 8);
    expect(prediction.nextPeriodStart, DateTime(2026, 2, 26));
    expect(prediction.daysUntilNextPeriod, 21);
    expect(prediction.ovulationDate, DateTime(2026, 2, 12));
  });

  test('returns null prediction when nothing is logged', () {
    expect(
      calculator.predict(
        cycles: const [],
        today: DateTime(2026, 2, 5),
        fallbackCycleLength: 28,
        fallbackPeriodLength: 5,
      ),
      isNull,
    );
  });
}
