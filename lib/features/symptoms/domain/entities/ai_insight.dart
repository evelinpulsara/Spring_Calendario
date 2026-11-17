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

  final int basedOnEntries;

  final String? model;

  bool get isFromAi => model != null;
}
