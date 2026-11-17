import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

class SpringAssistantCard extends StatelessWidget {
  const SpringAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final symptoms = context.watch<SymptomController>();
    final cycle = context.read<CycleController>();
    final insight = symptoms.insight;

    return SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              symptoms.isGenerating
                  ? const GentlePulse(
                      child: Icon(Icons.auto_awesome_rounded, color: AppColors.deepPink))
                  : const Icon(Icons.auto_awesome_rounded, color: AppColors.deepPink),
              const SizedBox(width: 8),
              Text(t.isSpanish ? 'Asistente Spring' : 'Spring Assistant',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, if (current != null) current],
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: symptoms.isGenerating
                  ? Row(
                      key: const ValueKey('thinking'),
                      children: [
                        const ThinkingDots(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.isSpanish
                                ? 'Analizando tu ciclo, síntomas y registros...'
                                : 'Looking at your cycle, symptoms and logs...',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    )
                  : insight == null
                      ? Text(
                          key: const ValueKey('empty'),
                          t.isSpanish
                              ? 'Pídele a Spring un consejo personalizado basado en tu ciclo y síntomas.'
                              : 'Ask Spring for a personalised insight based on your cycle and symptom logs.')
                      : Column(
                          key: ValueKey(insight.generatedAt),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(insight.title,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(insight.message, style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  insight.isFromAi
                                      ? Icons.auto_awesome_rounded
                                      : Icons.cloud_off_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    insight.isFromAi
                                        ? (t.isSpanish
                                            ? 'Generado con IA (${insight.model})'
                                            : 'Generated with AI (${insight.model})')
                                        : (t.isSpanish
                                            ? 'Respuesta local: el servidor de IA no está disponible'
                                            : 'Local answer: the AI server is not available'),
                                    style:
                                        const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: symptoms.isGenerating
                  ? null
                  : () => symptoms.generateInsight(
                        cycles: cycle.cycles,
                        prediction: cycle.prediction,
                        intimacy: context.read<IntimacyController>().riskReport(cycle.projection),
                      ),
              icon: symptoms.isGenerating
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.nightlight_round, size: 18),
              label: Text(symptoms.isGenerating
                  ? (t.isSpanish ? 'Spring está pensando...' : 'Spring is thinking...')
                  : insight == null
                      ? (t.isSpanish ? 'Generar consejo' : 'Generate insight')
                      : (t.isSpanish ? 'Actualizar consejo' : 'Refresh insight')),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.disclaimer,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
