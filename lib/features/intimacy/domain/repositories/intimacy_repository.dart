import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';

/// Contrato para guardar las relaciones registradas.
abstract class IntimacyRepository {
  Future<List<IntimacyEntry>> getAll();

  /// Guarda (o reemplaza) el registro de ese día.
  Future<void> save(IntimacyEntry entry);

  Future<void> deleteForDate(DateTime date);

  Future<void> clear();
}
