/// Predicción del próximo periodo: ventana de días posibles, duración y ovulación.
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

  /// low, medium o high.
  final String confidence;
  final String explanation;

  /// Modelo de IA que hizo la predicción; null = cálculo local.
  final String? model;

  bool get isFromAi => model != null;
}
