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
