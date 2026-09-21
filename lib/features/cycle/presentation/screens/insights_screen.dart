import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final prediction = cycle.prediction;
    final avgCycle = cycle.averageCycleLength;
    final avgPeriod = cycle.averagePeriodLength;
    final top = symptoms.topSymptoms.take(5).toList();
    final maxCount = top.isEmpty ? 1 : top.first.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle insights')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.loop_rounded,
                    label: 'Average cycle',
                    value: avgCycle == null ? '--' : '${avgCycle.toStringAsFixed(1)} days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.water_drop_rounded,
                    label: 'Average period',
                    value: avgPeriod == null ? '--' : '${avgPeriod.toStringAsFixed(1)} days',
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
                    const SectionTitle('Predictions'),
                    _row('Next period', AppDateUtils.longDate(prediction.nextPeriodStart)),
                    _row('Estimated ovulation', AppDateUtils.longDate(prediction.ovulationDate)),
                    _row('Fertile window',
                        AppDateUtils.range(prediction.fertileWindowStart, prediction.fertileWindowEnd)),
                    _row('Current phase', prediction.phase.label),
                  ],
                ),
              ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Most common symptoms'),
                  if (top.isEmpty)
                    const Text('Log symptoms to see them here.',
                        style: TextStyle(color: AppColors.textMuted)),
                  for (final item in top)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(item.key.icon, size: 18, color: AppColors.purple),
                          const SizedBox(width: 10),
                          SizedBox(width: 110, child: Text(item.key.label)),
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
                  const SectionTitle('Recent cycle history'),
                  if (cycle.recentCycles.isEmpty)
                    const Text('No cycles yet.', style: TextStyle(color: AppColors.textMuted)),
                  for (final item in cycle.recentCycles)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.brightness_2_rounded, color: AppColors.deepPink),
                      title: Text('Started ${AppDateUtils.shortDate(item.startDate)}'),
                      subtitle: Text('Period: ${item.periodLength} days'),
                      trailing: Text(
                        item.isInProgress ? 'In progress' : '${item.cycleLength} day cycle',
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
