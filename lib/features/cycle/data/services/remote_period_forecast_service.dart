import 'package:http/http.dart' as http;
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/network/json_endpoint.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';
import 'package:spring_calendario/features/cycle/domain/services/period_forecast_service.dart';

class RemotePeriodForecastService with FallbackOnError implements PeriodForecastService {
  RemotePeriodForecastService({
    required PeriodForecastService fallback,
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.aiTimeout,
    HeadersProvider? headers,
  })  : _fallback = fallback,
        _endpoint = JsonEndpoint('/api/ai/prediction',
            client: client, baseUrl: baseUrl, timeout: timeout, headers: headers);

  static const int _lutealDays = 14;

  final PeriodForecastService _fallback;
  final JsonEndpoint _endpoint;

  @override
  String get fallbackReason => 'Predicción: se usa el cálculo local';

  @override
  Future<PeriodForecast> forecast(ForecastInput input) {
    return remoteOr(
      () async {
        final json = await _endpoint.post(buildRequestBody(input));
        return PeriodForecast(
          earliestStart: json.date('earliestStart'),
          likelyStart: json.date('likelyStart'),
          latestStart: json.date('latestStart'),
          periodLength: json.integer('periodLength', min: 1),
          ovulationDate: json.date('ovulationDate'),
          confidence: json.optionalString('confidence') ?? 'medium',
          explanation: json.optionalString('explanation') ?? '',
          model: json.optionalString('model') ?? 'gemini',
        );
      },
      () => _fallback.forecast(input),
    );
  }

  static Map<String, Object?> buildRequestBody(ForecastInput input) {
    const day = AppDateUtils.isoDate;
    final nextStart = input.baseline.nextPeriodStart;
    return {
      'language': AppLanguage.isSpanish ? 'es' : 'en',
      'today': day(input.today),
      'profile': {
        'ageGroup': input.ageGroup.name,
        'regularity': input.regularity.name,
        'typicalPeriodLength': input.typicalPeriodLength,
        'typicalCycleLength': input.typicalCycleLength,
      },
      'cycles': [
        for (final c in input.cycles)
          {
            'startDate': day(c.startDate),
            'periodLength': c.periodLength,
            'cycleLength': c.cycleLength,
          },
      ],
      'baseline': {
        'nextStart': day(nextStart),
        'periodLength': input.expectedPeriodLength,
        'ovulation': day(AppDateUtils.addDays(nextStart, -_lutealDays)),
      },
    };
  }
}
