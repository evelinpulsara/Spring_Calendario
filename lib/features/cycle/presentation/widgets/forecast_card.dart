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
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(a),
                child: child,
              ),
            ),
            child: _ForecastBody(
              key: ValueKey('${forecast.likelyStart}-${forecast.model}-${forecast.earliestStart}'),
              forecast: forecast,
              isLight: isLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastBody extends StatelessWidget {
  const _ForecastBody({super.key, required this.forecast, required this.isLight});

  final PeriodForecast forecast;
  final bool isLight;

  String get _confidenceLabel {
    switch (forecast.confidence) {
      case 'high':
        return AppLanguage.tr('Confianza alta', 'High confidence');
      case 'low':
        return AppLanguage.tr('Confianza baja', 'Low confidence');
      default:
        return AppLanguage.tr('Confianza media', 'Medium confidence');
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = forecast;
    final sameDay = AppDateUtils.isSameDay(f.earliestStart, f.latestStart);
    final days = <DateTime>[
      for (var d = f.earliestStart; !d.isAfter(f.latestStart); d = AppDateUtils.addDays(d, 1)) d,
    ];

    Widget info(IconData icon, String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lavenderSoft : AppColors.night,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: AppColors.purple),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sameDay
              ? AppDateUtils.longDate(f.likelyStart)
              : AppDateUtils.range(f.earliestStart, f.latestStart),
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.deepPink),
        ),
        const SizedBox(height: 8),
        // Días posibles de inicio; el más probable resaltado.
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < days.length; i++)
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * i),
                offsetY: 8,
                child: _DayPill(
                  date: days[i],
                  likely: AppDateUtils.isSameDay(days[i], f.likelyStart),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            info(Icons.water_drop_rounded, AppLanguage.tr('Duración probable', 'Likely length'),
                AppLanguage.tr('${f.periodLength} días', '${f.periodLength} days')),
            const SizedBox(width: 8),
            info(Icons.brightness_2_rounded, AppLanguage.tr('Ovulación', 'Ovulation'),
                AppDateUtils.shortDate(f.ovulationDate)),
            const SizedBox(width: 8),
            info(Icons.verified_rounded, AppLanguage.tr('Predicción', 'Forecast'),
                _confidenceLabel),
          ],
        ),
        if (f.explanation.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(f.explanation, style: const TextStyle(height: 1.4)),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(f.isFromAi ? Icons.auto_awesome_rounded : Icons.calculate_rounded,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                f.isFromAi
                    ? AppLanguage.tr('Predicción con IA (${f.model})', 'AI forecast (${f.model})')
                    : AppLanguage.tr('Cálculo local (la IA no está disponible)',
                        'Local estimate (AI not available)'),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
