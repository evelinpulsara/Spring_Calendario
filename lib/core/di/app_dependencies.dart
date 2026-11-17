import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/di/repository_factory.dart';
import 'package:spring_calendario/core/l10n/locale_controller.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/core/realtime/realtime_sync.dart';
import 'package:spring_calendario/core/theme/theme_controller.dart';
import 'package:spring_calendario/core/web/browser_features.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/data/repositories/local_prediction_repository.dart';
import 'package:spring_calendario/features/cycle/data/services/local_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/data/services/remote_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/data/services/mock_ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/data/services/remote_ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';

class AppDependencies {
  AppDependencies._({
    required this.sessionController,
    required this.cycleController,
    required this.symptomController,
    required this.themeController,
    required this.localeController,
    required this.intimacyController,
    required this.realtimeService,
  });

  factory AppDependencies({bool useBackend = ApiConfig.useBackend}) {
    final api = ApiClient();
    final repositories = RepositoryFactory(useBackend: useBackend, api: api);
    Map<String, String> headers() => api.authHeaders;

    const calculator = CycleCalculator();
    final cycleRepository = repositories.cycles();

    final session = SessionController(repositories.users());
    final cycle = CycleController(
      cycleRepository: cycleRepository,
      predictionRepository: LocalPredictionRepository(
        cycleRepository: cycleRepository,
        calculator: calculator,
      ),
      calculator: calculator,
      currentUser: () => session.user,
      forecastService: RemotePeriodForecastService(
        fallback: const LocalPeriodForecastService(),
        headers: headers,
      ),
    );
    final symptoms = SymptomController(
      repository: repositories.symptoms(),
      aiInsightService: RemoteAiInsightService(fallback: MockAiInsightService(), headers: headers),
    );
    final intimacy = IntimacyController(repository: repositories.intimacy());
    final realtime = RealtimeService(api);

    if (useBackend) {
      RealtimeSync(realtime, {
        RealtimeResource.periodDays: cycle.load,
        RealtimeResource.symptoms: symptoms.load,
        RealtimeResource.intimacy: intimacy.load,
      }).attach();
      BrowserFeatures.onVisibilityChange((hidden) => hidden ? realtime.pause() : realtime.resume());
    }

    session.addListener(() {
      if (session.isLoggedIn) {
        cycle.load().catchError((Object e) => debugPrint('No se pudo cargar el ciclo: $e'));
        if (useBackend) realtime.start();
      } else {
        realtime.stop();
      }
    });

    return AppDependencies._(
      sessionController: session,
      cycleController: cycle,
      symptomController: symptoms,
      themeController: ThemeController(),
      localeController: LocaleController(),
      intimacyController: intimacy,
      realtimeService: realtime,
    );
  }

  final SessionController sessionController;
  final CycleController cycleController;
  final SymptomController symptomController;
  final ThemeController themeController;
  final LocaleController localeController;
  final IntimacyController intimacyController;
  final RealtimeService realtimeService;
}
