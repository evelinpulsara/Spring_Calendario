import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';

abstract class SymptomRepository {
  Future<List<SymptomEntry>> getAllEntries();

  Future<void> saveEntriesForDate(DateTime date, List<SymptomEntry> entries);

  Future<void> clear();
}
