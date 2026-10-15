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
