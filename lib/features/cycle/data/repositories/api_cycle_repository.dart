import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';

/// Días de periodo guardados en la base de datos.
class ApiCycleRepository implements CycleRepository {
  ApiCycleRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<PeriodEntry>> getPeriodEntries() async {
    final list = await _api.get('/api/period-days') as List<dynamic>;
    return [
      for (final j in list.cast<Map<String, dynamic>>())
        PeriodEntry(
          id: 'period-${j['date']}',
