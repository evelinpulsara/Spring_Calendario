class MenstrualCycle {
  const MenstrualCycle({
    required this.startDate,
    required this.periodLength,
    this.cycleLength,
  });

  final DateTime startDate;

  final int periodLength;

  final int? cycleLength;

  bool get isInProgress => cycleLength == null;
}
