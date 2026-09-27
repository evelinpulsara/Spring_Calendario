import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';

/// A symptom recorded on a specific day. Intensity goes from 1 (mild) to 5 (strong).
class SymptomEntry {
  const SymptomEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.intensity,
  });

  final String id;
  final DateTime date;
  final SymptomType type;
  final int intensity;
}
