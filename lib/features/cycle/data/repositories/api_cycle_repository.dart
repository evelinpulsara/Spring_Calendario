import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';

class ApiCycleRepository implements CycleRepository {
  ApiCycleRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<PeriodEntry>> getPeriodEntries() async {
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

  @override
  Future<void> clear() => _api.delete('/api/me/data');
}
