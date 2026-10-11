import 'package:flutter/material.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';

extension ProtectionTypeVisuals on ProtectionType {
  IconData get icon {
    switch (this) {
      case ProtectionType.none:
        return Icons.favorite_rounded;
      case ProtectionType.condom:
        return Icons.shield_rounded;
      case ProtectionType.contraceptive:
        return Icons.medication_rounded;
      case ProtectionType.unsure:
        return Icons.help_rounded;
    }
  }
}

extension PregnancyRiskVisuals on PregnancyRisk {
