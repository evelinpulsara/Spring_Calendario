import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_phase.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/widgets/forecast_card.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/intimacy_sheet.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/pregnancy_risk_card.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:spring_calendario/features/symptoms/presentation/widgets/spring_assistant_card.dart';
import 'package:spring_calendario/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';
import 'package:spring_calendario/shared/widgets/moon_widget.dart';
import 'package:spring_calendario/shared/widgets/section_title.dart';
import 'package:spring_calendario/shared/widgets/stat_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<SessionController>().user;
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final intimacy = context.watch<IntimacyController>();
    final prediction = cycle.prediction;
    final today = AppDateUtils.today();
    final urgentRisk = intimacy.urgentRisk(cycle.projection);
    final hasIntimacyToday = intimacy.hasEntry(today);

    return Scaffold(
      body: SafeArea(
        child: StaggeredListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              t.isSpanish ? 'Hola, ${user?.name ?? 'amiga'}' : 'Hello, ${user?.name ?? 'there'}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(AppDateUtils.longDate(today),
                  style: const TextStyle(color: AppColors.textMuted)),
            ),
            if (prediction == null)
              _EmptyCycleCard(onLogToday: () => cycle.setPeriodDay(today))
            else
              _CycleHeroCard(prediction: prediction),
            if (urgentRisk != null) PregnancyRiskCard(info: urgentRisk),
            if (prediction != null) const ForecastCard(),
            if (prediction != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.water_drop_rounded,
                        label: t.nextPeriod,
                        value: cycle.forecast == null
                          ? AppDateUtils.shortDate(prediction.nextPeriodStart)
                          : AppDateUtils.range(
                              cycle.forecast!.earliestStart, cycle.forecast!.latestStart),
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
              ),
          ],
          sideChildren: [
            SpringCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.isSpanish ? 'Síntomas de hoy' : "Today's symptoms"),
                  if (symptoms.todayEntries.isEmpty)
