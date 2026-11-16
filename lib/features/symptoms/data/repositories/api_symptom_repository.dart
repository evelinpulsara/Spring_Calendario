import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/domain/repositories/symptom_repository.dart';

/// Síntomas guardados en la base de datos.
class ApiSymptomRepository implements SymptomRepository {
  ApiSymptomRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<SymptomEntry>> getAllEntries() async {
    // Se parsea según el contrato (Symptom en openapi.yaml).
    final list = JsonObject.parseList(await _api.get('/api/symptoms'), 'symptoms');
    return [
      for (final j in list)
        SymptomEntry(
          id: '${j.string('date')}-${j.string('type')}',
          date: j.date('date'),
          type: j.enumValue('type', SymptomType.values),
          intensity: j.integer('intensity', min: 1, max: 5),
        ),
    ];
  }

  @override
  Future<void> saveEntriesForDate(DateTime date, List<SymptomEntry> entries) => _api.put(
        '/api/symptoms/${ApiClient.date(date)}',
        [for (final e in entries) {'type': e.type.name, 'intensity': e.intensity}],
      );

  /// Los datos se borran juntos con DELETE /api/me/data (ver ApiCycleRepository).
  @override
  Future<void> clear() async {}
}
