import 'dart:math' as math;

import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_phase.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';

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

  final Set<DateTime> possibleStartDays;

  final Set<DateTime> expectedPeriodDays;

  static const CycleProjection empty = CycleProjection(
    predictedPeriodDays: {},
    fertileDays: {},
    ovulationDays: {},
  );
}

class CycleCalculator {
  const CycleCalculator();

  List<MenstrualCycle> buildCycles(List<PeriodEntry> entries) {
    if (entries.isEmpty) return const [];

    final days = entries.map((e) => AppDateUtils.dateOnly(e.date)).toSet().toList()
      ..sort();

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

    var currentStart = cycles.last.startDate;
    final DateTime nextStart;
    if (override != null &&
        AppDateUtils.daysBetween(currentStart, override.likelyStart) >= 15) {
      nextStart = override.likelyStart;
      cycleLength = AppDateUtils.daysBetween(currentStart, nextStart);
    } else {
      while (AppDateUtils.daysBetween(currentStart, today) >= cycleLength) {
        currentStart = AppDateUtils.addDays(currentStart, cycleLength);
      }
      nextStart = AppDateUtils.addDays(currentStart, cycleLength);
    }
    final cycleDay = math.max(1, AppDateUtils.daysBetween(currentStart, today) + 1);

    final ovulationDay = override != null && override.ovulationDate.isAfter(currentStart)
        ? AppDateUtils.daysBetween(currentStart, override.ovulationDate) + 1
        : cycleLength - AppConstants.lutealPhaseLength + 1;

    var ovulation = AppDateUtils.addDays(currentStart, ovulationDay - 1);
    if (ovulation.isBefore(today)) {
      ovulation = AppDateUtils.addDays(nextStart, ovulationDay - 1);
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
    final lastCycle = cycles.last;
    final useOverride = override != null &&
        AppDateUtils.daysBetween(lastCycle.startDate, override.likelyStart) >= 15;

    final period = <DateTime>{};
    final fertile = <DateTime>{};
    final ovulation = <DateTime>{};

    void addFertility(DateTime cycleStart, int length) {
      final ovulationDate =
          AppDateUtils.addDays(cycleStart, length - AppConstants.lutealPhaseLength);
      ovulation.add(ovulationDate);
      for (var i = -AppConstants.fertileDaysBeforeOvulation;
          i <= AppConstants.fertileDaysAfterOvulation;
          i++) {
        fertile.add(AppDateUtils.addDays(ovulationDate, i));
      }
    }

    for (final cycle in cycles) {
      if (cycle == lastCycle && useOverride) {
        ovulation.add(override.ovulationDate);
        for (var i = -AppConstants.fertileDaysBeforeOvulation;
            i <= AppConstants.fertileDaysAfterOvulation;
            i++) {
          fertile.add(AppDateUtils.addDays(override.ovulationDate, i));
        }
      } else {
        addFertility(cycle.startDate, cycle.cycleLength ?? cycleLength);
      }
    }

    final firstStart = useOverride
        ? override.likelyStart
        : AppDateUtils.addDays(lastCycle.startDate, cycleLength);
    for (var k = 0; k < futureCycles; k++) {
      final start = AppDateUtils.addDays(firstStart, cycleLength * k);
      for (var d = 0; d < periodLength; d++) {
        period.add(AppDateUtils.addDays(start, d));
      }
      addFertility(start, cycleLength);
    }

    final possible = <DateTime>{};
    if (useOverride) {
      for (var d = override.earliestStart;
          !d.isAfter(override.latestStart);
          d = AppDateUtils.addDays(d, 1)) {
        possible.add(d);
      }
    } else {
      for (var i = -1; i <= 1; i++) {
        possible.add(AppDateUtils.addDays(firstStart, i));
      }
    }

    final expected = <DateTime>{};
    if (lastCycle.periodLength < periodLength) {
      for (var d = lastCycle.periodLength; d < periodLength; d++) {
        expected.add(AppDateUtils.addDays(lastCycle.startDate, d));
      }
    }

    return CycleProjection(
      predictedPeriodDays: period,
      fertileDays: fertile,
      ovulationDays: ovulation,
      possibleStartDays: possible,
      expectedPeriodDays: expected,
    );
  }
}

class PredictionOverride {
  const PredictionOverride({
    required this.earliestStart,
    required this.likelyStart,
    required this.latestStart,
    required this.periodLength,
    required this.ovulationDate,
  });

  final DateTime earliestStart;
  final DateTime likelyStart;
  final DateTime latestStart;
  final int periodLength;
  final DateTime ovulationDate;
}
