import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';

abstract class CycleRepository {
  Future<List<PeriodEntry>> getPeriodEntries();

  Future<void> savePeriodEntry(PeriodEntry entry);

  Future<void> deletePeriodEntry(DateTime date);

  Future<void> clear();
}
