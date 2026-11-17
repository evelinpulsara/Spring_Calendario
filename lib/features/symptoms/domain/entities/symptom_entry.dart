import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';

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
