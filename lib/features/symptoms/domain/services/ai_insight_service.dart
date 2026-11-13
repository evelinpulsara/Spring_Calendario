import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/ai_insight.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';

/// Contract for the "Spring Assistant".
///
/// The MVP uses `MockAiInsightService`. To use a real AI provider, create a new
/// class that implements this interface and register it in `AppDependencies`.
abstract class AiInsightService {
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,

    /// Relaciones registradas con su riesgo estimado (más recientes primero).
    List<IntimacyRiskInfo> intimacy = const [],
  });
}
