/// A text insight produced by Spring Assistant.
class AiInsight {
  const AiInsight({
    required this.title,
    required this.message,
    required this.generatedAt,
    required this.basedOnEntries,
    this.model,
  });

  final String title;
  final String message;
  final DateTime generatedAt;

  /// How many symptom entries were used to build the insight.
  final int basedOnEntries;

  /// Modelo de IA que generó el consejo (por ejemplo "gemini-3.8-flash").
  /// Es `null` cuando el consejo es la respuesta local de respaldo.
  final String? model;

  bool get isFromAi => model != null;
}
