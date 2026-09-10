import 'package:lunaflow/features/cycle/domain/entities/cycle_phase.dart';

/// Estimated information about the current and next cycle.
class CyclePrediction {
  const CyclePrediction({
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phase,
    required this.daysUntilNextPeriod,
    required this.nextPeriodStart,
    required this.nextPeriodEnd,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
  });

  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;
  final int daysUntilNextPeriod;
  final DateTime nextPeriodStart;
  final DateTime nextPeriodEnd;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
}
