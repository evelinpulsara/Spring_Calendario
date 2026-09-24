/// A text insight produced by Luna Assistant.
class AiInsight {
  const AiInsight({
    required this.title,
    required this.message,
    required this.generatedAt,
    required this.basedOnEntries,
  });

  final String title;
  final String message;
  final DateTime generatedAt;

  /// How many symptom entries were used to build the insight.
  final int basedOnEntries;
}
