import 'package:http/http.dart' as http;
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/network/json_endpoint.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/ai_insight.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/services/ai_insight_service.dart';

class RemoteAiInsightService with FallbackOnError implements AiInsightService {
  RemoteAiInsightService({
    required AiInsightService fallback,
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.aiTimeout,
    HeadersProvider? headers,
  })  : _fallback = fallback,
        _endpoint = JsonEndpoint('/api/ai/insight',
            client: client, baseUrl: baseUrl, timeout: timeout, headers: headers);

  final AiInsightService _fallback;
  final JsonEndpoint _endpoint;

  @override
  String get fallbackReason => 'Asistente Spring: se usa la respuesta local';

  @override
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
    List<IntimacyRiskInfo> intimacy = const [],
  }) {
    return remoteOr(
      () async {
        final json = await _endpoint.post(buildRequestBody(
          symptoms: symptoms,
          cycles: cycles,
          prediction: prediction,
          intimacy: intimacy,
        ));
        return AiInsight(
          title: json.string('title'),
          message: json.string('message'),
          basedOnEntries: json.optionalInteger('basedOnEntries') ?? symptoms.length,
          generatedAt: DateTime.now(),
          model: json.optionalString('model') ?? 'gemini',
        );
      },
      () => _fallback.generateInsight(
        symptoms: symptoms,
        cycles: cycles,
        prediction: prediction,
        intimacy: intimacy,
      ),
    );
  }

  static Map<String, Object?> buildRequestBody({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
    List<IntimacyRiskInfo> intimacy = const [],
  }) {
    const day = AppDateUtils.isoDate;
    return {
      'language': AppLanguage.isSpanish ? 'es' : 'en',
      'symptoms': [
        for (final s in symptoms)
          {'date': day(s.date), 'type': s.type.name, 'intensity': s.intensity},
      ],
      'cycles': [
        for (final c in cycles)
          {
            'startDate': day(c.startDate),
            'periodLength': c.periodLength,
            'cycleLength': c.cycleLength,
          },
      ],
      'intimacy': [
        for (final i in intimacy)
          {
            'date': day(i.entry.date),
            'protection': i.entry.protection.name,
            'inFertileWindow': i.inFertileWindow,
            'ovulationDay': i.isOvulationDay,
            'risk': i.risk.name,
            'daysAgo': i.daysAgo,
          },
      ],
      'prediction': prediction == null
          ? null
          : {
              'cycleDay': prediction.cycleDay,
              'cycleLength': prediction.cycleLength,
              'phase': prediction.phase.name,
              'daysUntilNextPeriod': prediction.daysUntilNextPeriod,
            },
    };
  }
}
