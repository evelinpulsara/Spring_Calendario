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
