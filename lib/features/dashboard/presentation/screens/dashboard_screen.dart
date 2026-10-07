import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/l10n/app_localizations.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_phase.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/luna_assistant_card.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';
import 'package:lunaflow/shared/widgets/moon_widget.dart';
import 'package:lunaflow/shared/widgets/section_title.dart';
import 'package:lunaflow/shared/widgets/stat_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<SessionController>().user;
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final prediction = cycle.prediction;
    final today = AppDateUtils.today();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              t.isSpanish
                  ? 'Hola, ${user?.name ?? 'amiga'}'
                  : 'Hello, ${user?.name ?? 'there'}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            Text(AppDateUtils.longDate(today),
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            if (prediction == null)
              _EmptyCycleCard(onLogToday: () => cycle.setPeriodDay(today))
            else ...[
              _CycleHeroCard(prediction: prediction),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.water_drop_rounded,
                      label: t.nextPeriod,
                      value: AppDateUtils.shortDate(prediction.nextPeriodStart),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      icon: Icons.brightness_2_rounded,
                      label: t.isSpanish ? 'Ovulación' : 'Ovulation',
                      value: AppDateUtils.shortDate(prediction.ovulationDate),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      icon: Icons.spa_rounded,
                      label: t.fertileWindow,
                      value: AppDateUtils.range(
                          prediction.fertileWindowStart, prediction.fertileWindowEnd),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.isSpanish ? 'Síntomas de hoy' : "Today's symptoms"),
                  if (symptoms.todayEntries.isEmpty)
                    Text(t.noSymptomsYet,
                        style: const TextStyle(color: AppColors.textMuted))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in symptoms.todayEntries)
                          Chip(
                            avatar: Icon(entry.type.icon, size: 16, color: AppColors.purple),
                            label: Text('${entry.type.label} - ${entry.intensity}/5'),
                            backgroundColor: AppColors.purple.withAlpha(35),
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.isSpanish ? 'Registro rápido' : 'Quick log'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final type in SymptomType.values)
                        ActionChip(
                          avatar: Icon(type.icon, size: 16, color: AppColors.purple),
                          label: Text(type.label),
                          backgroundColor: AppColors.lavender.withAlpha(120),
                          side: BorderSide.none,
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.logSymptoms,
                            arguments: LogSymptomsArgs(preselected: type),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => cycle.togglePeriodDay(today),
                      icon: Icon(cycle.isPeriodDay(today)
                          ? Icons.check_circle_rounded
                          : Icons.water_drop_outlined),
                      label: Text(cycle.isPeriodDay(today)
                          ? (t.isSpanish
                              ? 'Menstruación registrada (toca para deshacer)'
                              : 'Period logged today (tap to undo)')
                          : (t.isSpanish
                              ? 'Mi menstruación empezó hoy'
                              : 'My period started today')),
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
}

class _CycleHeroCard extends StatelessWidget {
  const _CycleHeroCard({required this.prediction});

  final CyclePrediction prediction;

  String _countdown(AppLocalizations t) {
    final days = prediction.daysUntilNextPeriod;
    if (t.isSpanish) {
      if (days <= 0) return 'Menstruación esperada hoy';
      if (days == 1) return 'Menstruación esperada mañana';
      return 'Próxima menstruación en $days días';
    } else {
      if (days <= 0) return 'Period expected today';
      if (days == 1) return 'Period expected tomorrow';
      return 'Next period in $days days';
    }
  }

  String _phaseLabel(AppLocalizations t) {
    switch (prediction.phase) {
      case CyclePhase.menstrual:  return t.menstrualPhase;
      case CyclePhase.follicular: return t.follicularPhase;
      case CyclePhase.ovulation:  return t.ovulationPhase;
      case CyclePhase.luteal:     return t.lutealPhase;
    }
  }

  String _phaseDescription(AppLocalizations t) {
    switch (prediction.phase) {
      case CyclePhase.menstrual:
        return t.isSpanish
            ? 'Buen momento para descansar, hidratarte y ser amable contigo misma.'
            : prediction.phase.description;
      case CyclePhase.follicular:
        return t.isSpanish
            ? 'La energía suele aumentar. Ideal para planificar y nuevas rutinas.'
            : prediction.phase.description;
      case CyclePhase.ovulation:
        return t.isSpanish
            ? 'Pico fértil estimado de tu ciclo.'
            : prediction.phase.description;
      case CyclePhase.luteal:
        return t.isSpanish
            ? 'Algunos síntomas premenstruales pueden aparecer. Registra cómo te sientes.'
            : prediction.phase.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final progress = ((prediction.cycleDay - 1) / prediction.cycleLength).clamp(0.0, 1.0);
    return LunarCard(
      gradient: AppColors.heroGradient,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_phaseLabel(t),
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 12),
                Text(
                  t.isSpanish
                      ? 'Día ${prediction.cycleDay}'
                      : 'Day ${prediction.cycleDay}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                ),
                Text(
                  t.isSpanish
                      ? 'de un ciclo de ${prediction.cycleLength} días'
                      : 'of ${prediction.cycleLength}-day cycle',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(_countdown(t),
                    style: const TextStyle(
                        color: AppColors.softPink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_phaseDescription(t),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MoonWidget(size: 108, progress: progress.toDouble()),
        ],
      ),
    );
  }
}

class _EmptyCycleCard extends StatelessWidget {
  const _EmptyCycleCard({required this.onLogToday});

  final VoidCallback onLogToday;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LunarCard(
      gradient: AppColors.heroGradient,
      child: Column(
        children: [
          const MoonWidget(size: 90, progress: 0.05),
          const SizedBox(height: 12),
          Text(
            t.isSpanish
                ? 'Registra tu primera menstruación para desbloquear predicciones'
                : 'Log your first period to unlock predictions',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppColors.deepPurple),
            onPressed: onLogToday,
            child: Text(t.isSpanish
                ? 'Mi menstruación empezó hoy'
                : 'My period started today'),
          ),
        ],
      ),
    );
  }
}
