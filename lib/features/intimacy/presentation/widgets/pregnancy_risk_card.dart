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
