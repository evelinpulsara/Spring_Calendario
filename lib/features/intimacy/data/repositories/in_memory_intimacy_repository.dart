import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';

/// Guarda las relaciones en memoria (igual que el resto del prototipo).
class InMemoryIntimacyRepository implements IntimacyRepository {
  final Map<DateTime, IntimacyEntry> _byDate = {};

  @override
  Future<List<IntimacyEntry>> getAll() async =>
      _byDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));

