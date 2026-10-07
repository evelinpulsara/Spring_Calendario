import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/l10n/app_localizations.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_phase.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/luna_assistant_card.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';
import 'package:lunaflow/shared/widgets/section_title.dart';
import 'package:lunaflow/shared/widgets/stat_tile.dart';

/// Simple calculated statistics about the user's cycles and symptoms.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final prediction = cycle.prediction;
    final avgCycle = cycle.averageCycleLength;
    final avgPeriod = cycle.averagePeriodLength;
    final top = symptoms.topSymptoms.take(5).toList();
    final maxCount = top.isEmpty ? 1 : top.first.value;

    return Scaffold(
      appBar: AppBar(title: Text(t.insights)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.loop_rounded,
                    label: t.averageCycle,
                    value: avgCycle == null
                        ? '--'
                        : '${avgCycle.toStringAsFixed(1)} ${t.days_label}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.water_drop_rounded,
                    label: t.averagePeriod,
                    value: avgPeriod == null
                        ? '--'
                        : '${avgPeriod.toStringAsFixed(1)} ${t.days_label}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (prediction != null)
              LunarCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(t.isSpanish ? 'Predicciones' : 'Predictions'),
                    _row(t.isSpanish ? 'Próxima menstruación' : 'Next period',
                        AppDateUtils.longDate(prediction.nextPeriodStart)),
                    _row(t.isSpanish ? 'Ovulación estimada' : 'Estimated ovulation',
                        AppDateUtils.longDate(prediction.ovulationDate)),
                    _row(t.fertileWindow,
                        AppDateUtils.range(prediction.fertileWindowStart, prediction.fertileWindowEnd)),
                    _row(t.currentPhase, _phaseLabel(prediction.phase, t)),
                  ],
                ),
              ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.topSymptoms),
                  if (top.isEmpty)
                    Text(t.isSpanish
                        ? 'Registra síntomas para verlos aquí.'
                        : 'Log symptoms to see them here.',
                        style: const TextStyle(color: AppColors.textMuted)),
                  for (final item in top)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(item.key.icon, size: 18, color: AppColors.purple),
                          const SizedBox(width: 10),
                          SizedBox(width: 110, child: Text(_symptomLabel(item.key, t))),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: item.value / maxCount,
                                minHeight: 10,
                                backgroundColor: AppColors.lavender,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(AppColors.purple),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${item.value}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.isSpanish ? 'Historial reciente de ciclos' : 'Recent cycle history'),
                  if (cycle.recentCycles.isEmpty)
                    Text(t.isSpanish ? 'Sin ciclos aún.' : 'No cycles yet.',
                        style: const TextStyle(color: AppColors.textMuted)),
                  for (final item in cycle.recentCycles)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.brightness_2_rounded, color: AppColors.deepPink),
                      title: Text(t.isSpanish
                          ? 'Inició el ${AppDateUtils.shortDate(item.startDate)}'
                          : 'Started ${AppDateUtils.shortDate(item.startDate)}'),
                      subtitle: Text(t.isSpanish
                          ? 'Período: ${item.periodLength} ${t.days_label}'
                          : 'Period: ${item.periodLength} days'),
                      trailing: Text(
                        item.isInProgress
                            ? (t.isSpanish ? 'En curso' : 'In progress')
                            : (t.isSpanish
                                ? 'Ciclo de ${item.cycleLength} días'
                                : '${item.cycleLength} day cycle'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            const LunaAssistantCard(),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(CyclePhase phase, AppLocalizations t) {
    switch (phase) {
      case CyclePhase.menstrual:
        return t.menstrualPhase;
      case CyclePhase.follicular:
        return t.follicularPhase;
      case CyclePhase.ovulation:
        return t.ovulationPhase;
      case CyclePhase.luteal:
        return t.lutealPhase;
    }
  }

  String _symptomLabel(SymptomType type, AppLocalizations t) {
    switch (type) {
      case SymptomType.cramps:   return t.cramps;
      case SymptomType.headache: return t.headache;
      case SymptomType.mood:     return t.mood;
      case SymptomType.bloating: return t.bloating;
      case SymptomType.acne:     return t.acne;
      case SymptomType.fatigue:  return t.fatigue;
      case SymptomType.appetite: return t.appetite;
      case SymptomType.sleep:    return t.sleep;
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
