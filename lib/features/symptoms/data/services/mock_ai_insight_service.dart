import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_phase.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:lunaflow/features/symptoms/domain/entities/ai_insight.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/domain/services/ai_insight_service.dart';

/// Local, rule-based implementation of [AiInsightService]. No network needed.
class MockAiInsightService implements AiInsightService {
  static const int _premenstrualWindowDays = 5;

  @override
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900)); // simulate latency

    if (symptoms.isEmpty) {
      return _build(
        'Welcome to Luna Assistant',
        'Log your symptoms for a few days and I will start looking for patterns in your cycle.',
        0,
      );
    }

    final parts = <String>[];
    final premenstrual = _premenstrualSymptoms(symptoms, cycles);
    if (premenstrual.isNotEmpty) {
      final names = _joinLabels(premenstrual);
      final plural = premenstrual.length > 1;
      parts.add('$names appear frequently in the days before your period, so LunaFlow may '
          'identify ${plural ? 'them as recurring premenstrual symptoms' : 'it as a recurring premenstrual symptom'}.');
    }

    final counts = <SymptomType, int>{};
    for (final entry in symptoms) {
      counts[entry.type] = (counts[entry.type] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    parts.add('Your most logged symptom is ${top.key.label.toLowerCase()} (${top.value} entries).');

    if (prediction != null) parts.add(_phaseTip(prediction));
    parts.add('This is a wellness insight, not medical advice.');

    return _build(
      premenstrual.isNotEmpty ? 'Possible premenstrual pattern' : 'Your symptom summary',
      parts.join(' '),
      symptoms.length,
    );
  }

  /// Symptoms logged in the days before at least two different periods.
  List<SymptomType> _premenstrualSymptoms(
    List<SymptomEntry> symptoms,
    List<MenstrualCycle> cycles,
  ) {
    final windowsWithSymptom = <SymptomType, int>{};
    for (var i = 1; i < cycles.length; i++) {
      final periodStart = cycles[i].startDate;
      final found = symptoms
          .where((s) {
            final diff = AppDateUtils.daysBetween(s.date, periodStart);
            return diff >= 1 && diff <= _premenstrualWindowDays;
          })
          .map((s) => s.type)
          .toSet();
      for (final type in found) {
        windowsWithSymptom[type] = (windowsWithSymptom[type] ?? 0) + 1;
      }
    }
    final recurring = windowsWithSymptom.entries.where((e) => e.value >= 2).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return recurring.take(3).map((e) => e.key).toList();
  }

  String _joinLabels(List<SymptomType> types) {
    final labels = types.map((t) => t.label.toLowerCase()).toList();
    final text = labels.length == 1
        ? labels.first
        : '${labels.sublist(0, labels.length - 1).join(', ')} and ${labels.last}';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _phaseTip(CyclePrediction prediction) {
    switch (prediction.phase) {
      case CyclePhase.menstrual:
        return 'You are in your menstrual phase: rest, warmth and hydration can feel good.';
      case CyclePhase.follicular:
        return 'You are in your follicular phase: many people feel more energetic now.';
      case CyclePhase.ovulation:
        return 'You are around your estimated ovulation window.';
      case CyclePhase.luteal:
        return 'You are in your luteal phase, so watch for premenstrual symptoms '
            'over the next ${prediction.daysUntilNextPeriod} days.';
    }
  }

  AiInsight _build(String title, String message, int count) {
    return AiInsight(
      title: title,
      message: message,
      generatedAt: DateTime.now(),
      basedOnEntries: count,
    );
  }
}
