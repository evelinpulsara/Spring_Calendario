import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:lunaflow/features/symptoms/domain/entities/ai_insight.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_entry.dart';

/// Contract for the "Luna Assistant".
///
/// The MVP uses `MockAiInsightService`. To use a real AI provider, create a new
/// class that implements this interface and register it in `AppDependencies`.
abstract class AiInsightService {
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
  });
}
