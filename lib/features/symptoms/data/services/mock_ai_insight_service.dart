import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_phase.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_guidance.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/ai_insight.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/domain/services/ai_insight_service.dart';

/// Local, rule-based implementation of [AiInsightService]. No network needed.
class MockAiInsightService implements AiInsightService {
  static const int _premenstrualWindowDays = 5;

  @override
  Future<AiInsight> generateInsight({
    required List<SymptomEntry> symptoms,
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
    List<IntimacyRiskInfo> intimacy = const [],
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900)); // simulate latency

    // Lo más importante primero: una relación reciente en la ventana fértil.
    final recent = intimacy.where((i) => i.daysAgo <= 7 && i.risk != PregnancyRisk.low).toList();
    if (recent.isNotEmpty) {
      final info = recent.first;
      return _build(
        PregnancyGuidance.title(info),
        '${PregnancyGuidance.message(info)} ${PregnancyGuidance.disclaimer}',
        symptoms.length,
      );
    }

    if (symptoms.isEmpty) {
      return _build(
        AppLanguage.tr('Bienvenida al Asistente Spring', 'Welcome to Spring Assistant'),
        AppLanguage.tr(
          'Registra tus síntomas durante unos días y empezaré a buscar patrones en tu ciclo.',
          'Log your symptoms for a few days and I will start looking for patterns in your cycle.',
        ),
        0,
      );
    }

    final parts = <String>[];
    final premenstrual = _premenstrualSymptoms(symptoms, cycles);
    if (premenstrual.isNotEmpty) {
      final names = _joinLabels(premenstrual);
      final plural = premenstrual.length > 1;
      parts.add(AppLanguage.isSpanish
          ? '$names ${plural ? 'aparecen' : 'aparece'} con frecuencia en los días antes de tu '
              'menstruación, así que Spring ${plural ? 'los identifica como síntomas premenstruales recurrentes' : 'lo identifica como un síntoma premenstrual recurrente'}.'
          : '$names appear frequently in the days before your period, so Spring may '
              'identify ${plural ? 'them as recurring premenstrual symptoms' : 'it as a recurring premenstrual symptom'}.');
    }

    final counts = <SymptomType, int>{};
    for (final entry in symptoms) {
      counts[entry.type] = (counts[entry.type] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    parts.add(AppLanguage.tr(
      'Tu síntoma más registrado es ${top.key.label.toLowerCase()} (${top.value} registros).',
      'Your most logged symptom is ${top.key.label.toLowerCase()} (${top.value} entries).',
    ));

    if (prediction != null) parts.add(_phaseTip(prediction));
    parts.add(AppLanguage.tr(
      'Esto es un consejo de bienestar, no un consejo médico.',
      'This is a wellness insight, not medical advice.',
    ));

    return _build(
      premenstrual.isNotEmpty
          ? AppLanguage.tr('Posible patrón premenstrual', 'Possible premenstrual pattern')
          : AppLanguage.tr('Resumen de tus síntomas', 'Your symptom summary'),
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
        : '${labels.sublist(0, labels.length - 1).join(', ')} '
            '${AppLanguage.tr('y', 'and')} ${labels.last}';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _phaseTip(CyclePrediction prediction) {
    switch (prediction.phase) {
      case CyclePhase.menstrual:
        return AppLanguage.tr(
          'Estás en tu fase menstrual: descansar, abrigarte e hidratarte puede sentarte bien.',
          'You are in your menstrual phase: rest, warmth and hydration can feel good.',
        );
      case CyclePhase.follicular:
        return AppLanguage.tr(
          'Estás en tu fase folicular: muchas personas se sienten con más energía ahora.',
          'You are in your follicular phase: many people feel more energetic now.',
        );
      case CyclePhase.ovulation:
        return AppLanguage.tr(
          'Estás cerca de tu ventana de ovulación estimada.',
          'You are around your estimated ovulation window.',
        );
      case CyclePhase.luteal:
        return AppLanguage.tr(
          'Estás en tu fase lútea, así que presta atención a síntomas premenstruales '
              'en los próximos ${prediction.daysUntilNextPeriod} días.',
          'You are in your luteal phase, so watch for premenstrual symptoms '
              'over the next ${prediction.daysUntilNextPeriod} days.',
        );
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
