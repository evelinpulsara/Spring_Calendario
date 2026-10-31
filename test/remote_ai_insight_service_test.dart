import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_phase.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/symptoms/data/services/remote_ai_insight_service.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/ai_insight.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/domain/services/ai_insight_service.dart';

class _FakeFallback implements AiInsightService {
  @override
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
    List<IntimacyRiskInfo> intimacy = const [],
  }) async =>
      AiInsight(title: 'local', message: 'local', generatedAt: DateTime(2026), basedOnEntries: 0);
}

final _symptoms = [
  SymptomEntry(id: '1', date: DateTime(2026, 10, 3), type: SymptomType.cramps, intensity: 4),
];
final _cycles = [MenstrualCycle(startDate: DateTime(2026, 10, 1), periodLength: 5)];
final _prediction = CyclePrediction(
  cycleDay: 3,
  cycleLength: 28,
  periodLength: 5,
  phase: CyclePhase.menstrual,
  daysUntilNextPeriod: 25,
  nextPeriodStart: DateTime(2026, 10, 29),
  nextPeriodEnd: DateTime(2026, 11, 2),
  ovulationDate: DateTime(2026, 10, 15),
  fertileWindowStart: DateTime(2026, 10, 10),
  fertileWindowEnd: DateTime(2026, 10, 16),
);

void main() {
  setUp(() => AppLanguage.isSpanish = true);

  test('envía el resumen al backend y devuelve el consejo de la IA', () async {
    late Map<String, dynamic> sent;
    final client = MockClient((request) async {
      expect(request.url.toString(), 'http://backend.test/api/ai/insight');
      sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response.bytes(
        utf8.encode(jsonEncode({
          'title': 'Cólicos al inicio',
          'message': 'Descansa y mantente hidratada.',
          'basedOnEntries': 1,
          'model': 'gemini-3.8-flash',
        })),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = RemoteAiInsightService(
      fallback: _FakeFallback(),
      client: client,
      baseUrl: 'http://backend.test',
    );

    final insight = await service.generateInsight(
      symptoms: _symptoms,
      cycles: _cycles,
      prediction: _prediction,
      intimacy: [
        IntimacyRiskInfo(
          entry: IntimacyEntry(
              id: 'i1', date: DateTime(2026, 10, 14), protection: ProtectionType.none),
          risk: PregnancyRisk.high,
          inFertileWindow: true,
          isOvulationDay: true,
          daysAgo: 2,
        ),
      ],
    );

    expect(insight.title, 'Cólicos al inicio');
    expect(insight.isFromAi, isTrue);
    expect(insight.model, 'gemini-3.8-flash');
    expect(sent['language'], 'es');
    expect(sent['symptoms'], [
      {'date': '2026-10-03', 'type': 'cramps', 'intensity': 4}
    ]);
    expect(sent['cycles'][0]['cycleLength'], isNull);
    expect(sent['prediction']['phase'], 'menstrual');
    expect(sent['intimacy'], [
      {
        'date': '2026-10-14',
        'protection': 'none',
        'inFertileWindow': true,
        'ovulationDay': true,
        'risk': 'high',
        'daysAgo': 2,
      }
    ]);
  });

  test('usa la respuesta local si el backend falla', () async {
    final client = MockClient((_) async => http.Response('{"error":"x"}', 503));
    final service = RemoteAiInsightService(
      fallback: _FakeFallback(),
      client: client,
      baseUrl: 'http://backend.test',
    );

    final insight = await service.generateInsight(symptoms: _symptoms, cycles: _cycles);

    expect(insight.title, 'local');
    expect(insight.isFromAi, isFalse);
  });
}
