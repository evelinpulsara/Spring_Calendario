import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';

class InMemoryIntimacyRepository implements IntimacyRepository {
  final Map<DateTime, IntimacyEntry> _byDate = {};

  @override
  Future<List<IntimacyEntry>> getAll() async =>
      _byDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  @override
  Future<void> save(IntimacyEntry entry) async {
    _byDate[AppDateUtils.dateOnly(entry.date)] = entry;
  }

  @override
  Future<void> deleteForDate(DateTime date) async {
    _byDate.remove(AppDateUtils.dateOnly(date));
  }

  @override
  Future<void> clear() async => _byDate.clear();
}
