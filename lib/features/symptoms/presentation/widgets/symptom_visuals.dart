import 'package:flutter/material.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';

/// Icons for each symptom (kept in the presentation layer on purpose).
extension SymptomTypeVisuals on SymptomType {
  IconData get icon {
    switch (this) {
      case SymptomType.cramps:
        return Icons.waves_rounded;
      case SymptomType.headache:
        return Icons.bolt_rounded;
      case SymptomType.mood:
        return Icons.mood_rounded;
      case SymptomType.bloating:
        return Icons.bubble_chart_rounded;
      case SymptomType.acne:
        return Icons.face_retouching_natural;
      case SymptomType.fatigue:
        return Icons.battery_alert_rounded;
      case SymptomType.appetite:
        return Icons.restaurant_rounded;
      case SymptomType.sleep:
        return Icons.nightlight_round;
    }
  }
}
