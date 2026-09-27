/// Symptoms the user can record.
enum SymptomType { cramps, headache, mood, bloating, acne, fatigue, appetite, sleep }

extension SymptomTypeLabel on SymptomType {
  String get label {
    switch (this) {
      case SymptomType.cramps:
        return 'Cramps';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.mood:
        return 'Mood changes';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.appetite:
        return 'Appetite changes';
      case SymptomType.sleep:
        return 'Sleep problems';
    }
  }
}
