import 'package:lunaflow/core/theme/theme_controller.dart';
import 'package:lunaflow/features/authentication/data/repositories/local_user_repository.dart';
import 'package:lunaflow/features/authentication/domain/repositories/user_repository.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';
import 'package:lunaflow/features/cycle/data/repositories/in_memory_cycle_repository.dart';
import 'package:lunaflow/features/cycle/data/repositories/local_prediction_repository.dart';
import 'package:lunaflow/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:lunaflow/features/cycle/domain/repositories/prediction_repository.dart';
import 'package:lunaflow/features/cycle/domain/services/cycle_calculator.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/data/repositories/in_memory_symptom_repository.dart';
import 'package:lunaflow/features/symptoms/data/services/mock_ai_insight_service.dart';
import 'package:lunaflow/features/symptoms/domain/repositories/symptom_repository.dart';
import 'package:lunaflow/features/symptoms/domain/services/ai_insight_service.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';

/// Composition root (manual dependency injection).
///
/// This is the ONLY place that knows which concrete implementations are used.
/// To connect a real backend or a real AI API, change the lines marked below.
class AppDependencies {
  AppDependencies._({
    required this.sessionController,
    required this.cycleController,
    required this.symptomController,
    required this.themeController,
  });

  factory AppDependencies() {
    // >>> DATABASE: replace these with Supabase / Firebase / REST implementations.
    final UserRepository userRepository = LocalUserRepository();
    final CycleRepository cycleRepository = InMemoryCycleRepository();
    final SymptomRepository symptomRepository = InMemorySymptomRepository();

    // >>> AI: replace with an OpenAI / Gemini / backend implementation.
    final AiInsightService aiInsightService = MockAiInsightService();

    const calculator = CycleCalculator();
    final PredictionRepository predictionRepository = LocalPredictionRepository(
      cycleRepository: cycleRepository,
      calculator: calculator,
    );

    final session = SessionController(userRepository);
    final cycle = CycleController(
      cycleRepository: cycleRepository,
      predictionRepository: predictionRepository,
      calculator: calculator,
      currentUser: () => session.user,
    );
    final symptoms = SymptomController(
      repository: symptomRepository,
      aiInsightService: aiInsightService,
    );

    // Predictions depend on the profile (fallback cycle/period length).
    session.addListener(() {
      cycle.load();
    });

    return AppDependencies._(
      sessionController: session,
      cycleController: cycle,
      symptomController: symptoms,
      themeController: ThemeController(),
    );
  }

  final SessionController sessionController;
  final CycleController cycleController;
  final SymptomController symptomController;
  final ThemeController themeController;
}
