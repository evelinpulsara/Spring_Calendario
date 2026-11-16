import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';

/// Días de periodo guardados en la base de datos.
class ApiCycleRepository implements CycleRepository {
  ApiCycleRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<PeriodEntry>> getPeriodEntries() async {
    // Se parsea según el contrato (PeriodDay en openapi.yaml).
    final list = JsonObject.parseList(await _api.get('/api/period-days'), 'period-days');
    return [
      for (final j in list)
        PeriodEntry(
          id: 'period-${j.string('date')}',
          date: j.date('date'),
          flow: j.enumValue('flow', FlowIntensity.values),
        ),
    ];
  }

  @override
  Future<void> savePeriodEntry(PeriodEntry entry) =>
      _api.put('/api/period-days/${ApiClient.date(entry.date)}', {'flow': entry.flow.name});

  @override
  Future<void> deletePeriodEntry(DateTime date) =>
      _api.delete('/api/period-days/${ApiClient.date(date)}');

  /// Borra todos los registros de la usuaria (periodo, síntomas y relaciones).
  @override
  Future<void> clear() => _api.delete('/api/me/data');
}
