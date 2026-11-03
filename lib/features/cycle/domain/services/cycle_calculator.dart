import 'dart:math' as math;

import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_phase.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';

/// Predicted days used to paint the calendar.
class CycleProjection {
  const CycleProjection({
    required this.predictedPeriodDays,
    required this.fertileDays,
    required this.ovulationDays,
    this.possibleStartDays = const {},
    this.expectedPeriodDays = const {},
  });

  final Set<DateTime> predictedPeriodDays;
  final Set<DateTime> fertileDays;
  final Set<DateTime> ovulationDays;

  /// Días en los que podría empezar el próximo periodo (ventana de la predicción).
  final Set<DateTime> possibleStartDays;

  /// Días que probablemente dure el periodo actual y aún no están registrados
  /// (se muestran con un rosa más opaco).
  final Set<DateTime> expectedPeriodDays;

  static const CycleProjection empty = CycleProjection(
    predictedPeriodDays: {},
    fertileDays: {},
    ovulationDays: {},
  );
}

/// Pure calculation logic (no Flutter, no storage), easy to unit test.
///
/// Simple, well-known estimation rules (NOT medical advice):
///  * next period = last period start + average cycle length
///  * ovulation  = next period start - 14 days
///  * fertile window = 5 days before ovulation up to 1 day after
class CycleCalculator {
  const CycleCalculator();

  /// Groups consecutive logged days into cycles, ordered oldest to newest.
  List<MenstrualCycle> buildCycles(List<PeriodEntry> entries) {
    if (entries.isEmpty) return const [];

    final days = entries.map((e) => AppDateUtils.dateOnly(e.date)).toSet().toList()
      ..sort();

    // Each block is [firstDay, lastDay]. A gap of 1 skipped day is tolerated.
    final blocks = <List<DateTime>>[];
    var start = days.first;
    var end = days.first;
    for (final day in days.skip(1)) {
      if (AppDateUtils.daysBetween(end, day) <= 2) {
        end = day;
      } else {
        blocks.add([start, end]);
        start = day;
        end = day;
      }
    }
    blocks.add([start, end]);

    final cycles = <MenstrualCycle>[];
    for (var i = 0; i < blocks.length; i++) {
      final hasNext = i + 1 < blocks.length;
      cycles.add(MenstrualCycle(
        startDate: blocks[i][0],
        periodLength: AppDateUtils.daysBetween(blocks[i][0], blocks[i][1]) + 1,
        cycleLength: hasNext ? AppDateUtils.daysBetween(blocks[i][0], blocks[i + 1][0]) : null,
      ));
    }
    return cycles;
  }

  double? averageCycleLength(List<MenstrualCycle> cycles) {
    final lengths = cycles
        .map((c) => c.cycleLength)
        .whereType<int>()
        .where((l) => l >= AppConstants.minValidCycleLength && l <= AppConstants.maxValidCycleLength)
        .toList();
    if (lengths.isEmpty) return null;
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  double? averagePeriodLength(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) return null;
    final total = cycles.map((c) => c.periodLength).reduce((a, b) => a + b);
    return total / cycles.length;
  }

  CyclePrediction? predict({
    required List<MenstrualCycle> cycles,
    required DateTime today,
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
    PredictionOverride? override,
  }) {
    if (cycles.isEmpty) return null;

    var cycleLength = (averageCycleLength(cycles) ?? fallbackCycleLength).round();
    final periodLength =
        override?.periodLength ?? (averagePeriodLength(cycles) ?? fallbackPeriodLength).round();

    // If the user forgot to log a period, keep projecting forward.
    var currentStart = cycles.last.startDate;
    final DateTime nextStart;
    if (override != null &&
        AppDateUtils.daysBetween(currentStart, override.likelyStart) >= 15) {
      // Predicción de la IA para el próximo inicio.
      nextStart = override.likelyStart;
      cycleLength = AppDateUtils.daysBetween(currentStart, nextStart);
    } else {
      while (AppDateUtils.daysBetween(currentStart, today) >= cycleLength) {
        currentStart = AppDateUtils.addDays(currentStart, cycleLength);
      }
      nextStart = AppDateUtils.addDays(currentStart, cycleLength);
    }
    final cycleDay = math.max(1, AppDateUtils.daysBetween(currentStart, today) + 1);

    // Cycle day on which ovulation is expected (1-based).
    final ovulationDay = override != null && override.ovulationDate.isAfter(currentStart)
        ? AppDateUtils.daysBetween(currentStart, override.ovulationDate) + 1
        : cycleLength - AppConstants.lutealPhaseLength + 1;

    var ovulation = AppDateUtils.addDays(currentStart, ovulationDay - 1);
    if (ovulation.isBefore(today)) {
      ovulation = AppDateUtils.addDays(nextStart, ovulationDay - 1); // next cycle
    }

    final CyclePhase phase;
    if (cycleDay <= periodLength) {
      phase = CyclePhase.menstrual;
    } else if (cycleDay < ovulationDay - 1) {
      phase = CyclePhase.follicular;
    } else if (cycleDay <= ovulationDay + 1) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    return CyclePrediction(
      cycleDay: cycleDay,
      cycleLength: cycleLength,
      periodLength: periodLength,
      phase: phase,
      daysUntilNextPeriod: AppDateUtils.daysBetween(today, nextStart),
      nextPeriodStart: nextStart,
      nextPeriodEnd: AppDateUtils.addDays(nextStart, periodLength - 1),
      ovulationDate: ovulation,
      fertileWindowStart: AppDateUtils.addDays(ovulation, -AppConstants.fertileDaysBeforeOvulation),
      fertileWindowEnd: AppDateUtils.addDays(ovulation, AppConstants.fertileDaysAfterOvulation),
    );
  }

  /// Projects period, fertile and ovulation days for the calendar.
  CycleProjection project({
    required List<MenstrualCycle> cycles,
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
    int futureCycles = 8,
    PredictionOverride? override,
  }) {
    if (cycles.isEmpty) return CycleProjection.empty;

    final cycleLength = (averageCycleLength(cycles) ?? fallbackCycleLength).round();
    final periodLength =
        override?.periodLength ?? (averagePeriodLength(cycles) ?? fallbackPeriodLength).round();
