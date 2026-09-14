import 'package:lunaflow/features/symptoms/domain/entities/symptom_entry.dart';

/// Contract for symptom data. Implement with Supabase, Firebase or a REST API.
abstract class SymptomRepository {
  Future<List<SymptomEntry>> getAllEntries();

  /// Replaces every entry of [date] with [entries].
  Future<void> saveEntriesForDate(DateTime date, List<SymptomEntry> entries);

  Future<void> clear();
}
