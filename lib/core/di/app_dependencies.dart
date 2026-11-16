import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/l10n/locale_controller.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/features/authentication/data/repositories/api_user_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/api_cycle_repository.dart';
import 'package:spring_calendario/features/intimacy/data/repositories/api_intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';
import 'package:spring_calendario/features/symptoms/data/repositories/api_symptom_repository.dart';
import 'package:spring_calendario/core/theme/theme_controller.dart';
import 'package:spring_calendario/features/authentication/data/repositories/local_user_repository.dart';
import 'package:spring_calendario/features/authentication/domain/repositories/user_repository.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/data/repositories/in_memory_cycle_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/local_prediction_repository.dart';
import 'package:spring_calendario/features/cycle/data/services/local_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/data/services/remote_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/prediction_repository.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/data/repositories/in_memory_intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/data/repositories/in_memory_symptom_repository.dart';
import 'package:spring_calendario/features/symptoms/data/services/mock_ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/data/services/remote_ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/domain/repositories/symptom_repository.dart';
import 'package:spring_calendario/features/symptoms/domain/services/ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';

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
    required this.localeController,
    required this.intimacyController,
    required this.realtimeService,
  });

  /// [useBackend]: true = datos en la base de datos (a través del backend);
  /// false = datos de prueba en memoria (sin servidor, usado en los tests).
  factory AppDependencies({bool useBackend = ApiConfig.useBackend}) {
    final api = ApiClient();

    // >>> BASE DE DATOS: backend Spring Boot + PostgreSQL (Supabase).
    final UserRepository userRepository =
        useBackend ? ApiUserRepository(api) : LocalUserRepository();
    final CycleRepository cycleRepository =
        useBackend ? ApiCycleRepository(api) : InMemoryCycleRepository();
    final SymptomRepository symptomRepository =
        useBackend ? ApiSymptomRepository(api) : InMemorySymptomRepository();
    final IntimacyRepository intimacyRepository =
        useBackend ? ApiIntimacyRepository(api) : InMemoryIntimacyRepository();

    // >>> IA: Gemini a través del backend (Spring_Backend). Si el backend no
    // está disponible, se usan las respuestas locales de MockAiInsightService.
    final AiInsightService aiInsightService = RemoteAiInsightService(
      fallback: MockAiInsightService(),
      headers: () => api.authHeaders,
    );

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
      // >>> IA: predicción del próximo periodo con Gemini (vía backend);
      // si el backend no responde, cálculo local.
      forecastService: RemotePeriodForecastService(
        fallback: const LocalPeriodForecastService(),
        headers: () => api.authHeaders,
      ),
    );
    final symptoms = SymptomController(
      repository: symptomRepository,
      aiInsightService: aiInsightService,
    );

    final intimacy = IntimacyController(repository: intimacyRepository);

    // >>> TIEMPO REAL (SSE): si la usuaria cambia algo en otro dispositivo o
    // pestaña, el backend avisa y aquí se recarga solo lo que cambió.
    final realtime = RealtimeService(api);
    if (useBackend) {
      final pending = <RealtimeResource>{};
      Timer? debounce;
      realtime.changes.listen((event) {
        // Debounce: varios cambios seguidos (ej. guardar 3 síntomas) = 1 recarga.
        pending.add(event.resource);
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 300), () {
          final all = pending.contains(RealtimeResource.all);
          void reload(String what, Future<void> Function() load) =>
              load().catchError((Object e) => debugPrint('No se pudo recargar $what: $e'));
          if (all || pending.contains(RealtimeResource.periodDays)) reload('el ciclo', cycle.load);
          if (all || pending.contains(RealtimeResource.symptoms)) reload('los síntomas', symptoms.load);
          if (all || pending.contains(RealtimeResource.intimacy)) reload('las relaciones', intimacy.load);
          pending.clear();
        });
      });
    }

    // Predictions depend on the profile (fallback cycle/period length).
    session.addListener(() {
      // Solo con sesión iniciada (sin token el backend respondería 401).
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
