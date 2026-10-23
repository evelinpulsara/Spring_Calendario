import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/ai_insight.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/services/ai_insight_service.dart';

/// Asistente Spring con IA real (Gemini).
///
/// La app NO llama a Gemini directamente: envía un resumen anónimo (síntomas,
/// ciclos y predicción, sin nombre ni correo) al backend, que guarda la clave
/// de la API y consulta a Gemini.
///
/// Si el backend no responde, usa [fallback] (respuestas locales) para que la
/// app siga funcionando.
class RemoteAiInsightService implements AiInsightService {
  RemoteAiInsightService({
    required AiInsightService fallback,
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.aiTimeout,
    Map<String, String> Function()? headers,
  })  : _fallback = fallback,
        _headers = headers ?? (() => const {'Content-Type': 'application/json'}),
        _client = client ?? http.Client(),
        _baseUrl = baseUrl,
        _timeout = timeout;

  final AiInsightService _fallback;
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  /// Headers de cada llamada (incluye el token de sesión).
  final Map<String, String> Function() _headers;

  @override
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
