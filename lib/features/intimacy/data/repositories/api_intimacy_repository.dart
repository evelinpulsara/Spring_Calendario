import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';

/// Relaciones registradas guardadas en la base de datos.
class ApiIntimacyRepository implements IntimacyRepository {
  ApiIntimacyRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<IntimacyEntry>> getAll() async {
    final list = await _api.get('/api/intimacy') as List<dynamic>;
    final types = ProtectionType.values.asNameMap();
    return [
      for (final j in list.cast<Map<String, dynamic>>())
        IntimacyEntry(
          id: 'intimacy-${j['date']}',
          date: DateTime.parse(j['date'] as String),
          protection: types[j['protection']] ?? ProtectionType.unsure,
        ),
    ];
  }

  @override
  Future<void> save(IntimacyEntry entry) => _api.put(
      '/api/intimacy/${ApiClient.date(entry.date)}', {'protection': entry.protection.name});

  @override
  Future<void> deleteForDate(DateTime date) =>
      _api.delete('/api/intimacy/${ApiClient.date(date)}');

  /// Los datos se borran juntos con DELETE /api/me/data (ver ApiCycleRepository).
  @override
  Future<void> clear() async {}
}
