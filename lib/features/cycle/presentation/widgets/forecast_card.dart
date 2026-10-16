import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

/// Tarjeta con la predicción del próximo periodo (hecha por la IA).
class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleController>();
    final forecast = cycle.forecast;
    if (forecast == null) return const SizedBox.shrink();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.deepPink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLanguage.tr('Predicción de tu próximo periodo', 'Your next period forecast'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: AppLanguage.tr('Actualizar predicción', 'Refresh forecast'),
                onPressed: cycle.isForecasting ? null : cycle.refreshForecast,
                icon: cycle.isForecasting
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
