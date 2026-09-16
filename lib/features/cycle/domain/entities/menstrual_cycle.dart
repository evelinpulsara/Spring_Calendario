/// A cycle derived from consecutive logged period days.
class MenstrualCycle {
  const MenstrualCycle({
    required this.startDate,
    required this.periodLength,
    this.cycleLength,
  });

  final DateTime startDate;

  /// Number of bleeding days in this cycle.
  final int periodLength;

  /// Days until the next period started. `null` while the cycle is in progress.
  final int? cycleLength;

  bool get isInProgress => cycleLength == null;
}
