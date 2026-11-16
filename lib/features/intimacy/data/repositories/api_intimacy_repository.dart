import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';

/// Relaciones registradas guardadas en la base de datos.
class ApiIntimacyRepository implements IntimacyRepository {
  ApiIntimacyRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<IntimacyEntry>> getAll() async {
    // Se parsea según el contrato (Intimacy en openapi.yaml).
    final list = JsonObject.parseList(await _api.get('/api/intimacy'), 'intimacy');
    return [
      for (final j in list)
        IntimacyEntry(
          id: 'intimacy-${j.string('date')}',
          date: j.date('date'),
          protection: j.enumValue('protection', ProtectionType.values),
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
