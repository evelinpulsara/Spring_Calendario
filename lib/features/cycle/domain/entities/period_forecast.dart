class PeriodForecast {
  const PeriodForecast({
    required this.earliestStart,
    required this.likelyStart,
    required this.latestStart,
    required this.periodLength,
    required this.ovulationDate,
    required this.confidence,
    required this.explanation,
    this.model,
  });

  final DateTime earliestStart;
  final DateTime likelyStart;
  final DateTime latestStart;
  final int periodLength;
  final DateTime ovulationDate;

  final String confidence;
  final String explanation;

  final String? model;

  bool get isFromAi => model != null;
}
