import 'package:lunaflow/features/cycle/domain/entities/period_entry.dart';

/// Contract for period data. Implement with Supabase, Firebase or a REST API.
abstract class CycleRepository {
  Future<List<PeriodEntry>> getPeriodEntries();

  /// Creates or replaces the entry for `entry.date`.
  Future<void> savePeriodEntry(PeriodEntry entry);

  Future<void> deletePeriodEntry(DateTime date);

  Future<void> clear();
}
