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
