import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';

abstract class IntimacyRepository {
  Future<List<IntimacyEntry>> getAll();

  Future<void> save(IntimacyEntry entry);

  Future<void> deleteForDate(DateTime date);

  Future<void> clear();
}
