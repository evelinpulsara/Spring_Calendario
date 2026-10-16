import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';
import 'package:spring_calendario/features/cycle/domain/services/period_forecast_service.dart';

/// Predicción del próximo periodo con IA (Gemini) a través del backend.
/// Si el backend no responde, usa [fallback] (cálculo local).
class RemotePeriodForecastService implements PeriodForecastService {
  RemotePeriodForecastService({
    required PeriodForecastService fallback,
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.aiTimeout,
    Map<String, String> Function()? headers,
  })  : _fallback = fallback,
        _headers = headers ?? (() => const {'Content-Type': 'application/json'}),
        _client = client ?? http.Client(),
        _baseUrl = baseUrl,
        _timeout = timeout;

  final PeriodForecastService _fallback;
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  /// Headers de cada llamada (incluye el token de sesión).
  final Map<String, String> Function() _headers;

  @override
  Future<PeriodForecast> forecast(ForecastInput input) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/ai/prediction'),
            headers: _headers(),
            body: jsonEncode(buildRequestBody(input)),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw Exception('Backend respondió ${response.statusCode}: ${response.body}');
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PeriodForecast(
        earliestStart: DateTime.parse(json['earliestStart'] as String),
        likelyStart: DateTime.parse(json['likelyStart'] as String),
        latestStart: DateTime.parse(json['latestStart'] as String),
        periodLength: (json['periodLength'] as num).toInt(),
        ovulationDate: DateTime.parse(json['ovulationDate'] as String),
        confidence: json['confidence'] as String? ?? 'medium',
        explanation: json['explanation'] as String? ?? '',
        model: json['model'] as String? ?? 'gemini',
      );
    } catch (error) {
      debugPrint('Predicción: se usa el cálculo local ($error)');
      return _fallback.forecast(input);
    }
  }

