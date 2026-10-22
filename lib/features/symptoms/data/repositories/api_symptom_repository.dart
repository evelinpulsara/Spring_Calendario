import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/domain/repositories/symptom_repository.dart';

/// Síntomas guardados en la base de datos.
class ApiSymptomRepository implements SymptomRepository {
  ApiSymptomRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<SymptomEntry>> getAllEntries() async {
    final list = await _api.get('/api/symptoms') as List<dynamic>;
    final types = SymptomType.values.asNameMap();
    return [
      for (final j in list.cast<Map<String, dynamic>>())
        if (types[j['type']] != null)
