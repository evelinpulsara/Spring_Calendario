import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';

/// Card that shows the latest Luna Assistant insight and lets the user refresh it.
class LunaAssistantCard extends StatelessWidget {
  const LunaAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    final symptoms = context.watch<SymptomController>();
    final cycle = context.read<CycleController>();
    final insight = symptoms.insight;

    return LunarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.deepPink),
              const SizedBox(width: 8),
              Text('Luna Assistant',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          if (insight == null)
            const Text('Ask Luna for a personalised insight based on your cycle and symptom logs.')
          else ...[
            Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(insight.message, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: symptoms.isGenerating
                  ? null
                  : () => symptoms.generateInsight(
                        cycles: cycle.cycles,
                        prediction: cycle.prediction,
                      ),
              icon: symptoms.isGenerating
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.nightlight_round, size: 18),
              label: Text(symptoms.isGenerating
                  ? 'Luna is thinking...'
                  : (insight == null ? 'Generate insight' : 'Refresh insight')),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppConstants.disclaimer,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
