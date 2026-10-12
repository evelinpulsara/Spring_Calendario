import 'package:flutter/material.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_guidance.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/intimacy_visuals.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

/// Aviso cálido cuando hay una relación reciente con posible riesgo de embarazo.
class PregnancyRiskCard extends StatelessWidget {
  const PregnancyRiskCard({super.key, required this.info, this.compact = false});

  final IntimacyRiskInfo info;

  /// Versión pequeña para el detalle del día en el calendario.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = info.risk.color;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GentlePulse(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withAlpha(40), shape: BoxShape.circle),
                child: Icon(
                  info.risk == PregnancyRisk.high ? Icons.favorite_rounded : Icons.info_rounded,
                  color: color,
                  size: compact ? 18 : 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // Título y etiqueta se acomodan en dos líneas si no hay espacio.
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    PregnancyGuidance.title(info),
                    style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(info.risk.label,
                        style:
                            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(PregnancyGuidance.message(info), style: const TextStyle(height: 1.45)),
        if (info.needsAttention && !compact) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lavenderSoft : AppColors.night,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.deepPurple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _timeLeft(info.daysAgo),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(PregnancyGuidance.disclaimer,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );

    if (compact) return content;
    return SpringCard(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: content,
      ),
    );
  }

  static String _timeLeft(int daysAgo) {
    if (daysAgo <= 0) {
      return AppLanguage.tr(
        'Fue hoy: estás dentro de las primeras 72 horas, el mejor momento para actuar.',
        'It was today: you are within the first 72 hours, the best time to act.',
      );
    }
    final hoursLeft72 = 72 - daysAgo * 24;
    if (hoursLeft72 > 0) {
      return AppLanguage.tr(
        'Aún estás dentro de las primeras 72 horas (quedan aprox. $hoursLeft72 h).',
        'You are still within the first 72 hours (about $hoursLeft72 h left).',
      );
    }
    final daysLeft = 5 - daysAgo;
    return AppLanguage.tr(
      'Pasaron las 72 h, pero algunas opciones funcionan hasta 5 días (queda${daysLeft == 1 ? '' : 'n'} $daysLeft día${daysLeft == 1 ? '' : 's'}).',
      '72 h have passed, but some options work up to 5 days ($daysLeft day${daysLeft == 1 ? '' : 's'} left).',
    );
  }
}
