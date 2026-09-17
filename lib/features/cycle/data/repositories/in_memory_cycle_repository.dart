import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/constants/demo_data.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';
import 'package:lunaflow/features/cycle/domain/entities/period_entry.dart';
import 'package:lunaflow/features/cycle/domain/repositories/cycle_repository.dart';

/// Stores period entries in memory. Replace with a database/API version later.
class InMemoryCycleRepository implements CycleRepository {
  InMemoryCycleRepository() {
    if (AppConstants.seedDemoData) _seed();
  }

  final Map<DateTime, PeriodEntry> _entries = {};

  @override
  Future<List<PeriodEntry>> getPeriodEntries() async {
    final list = _entries.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<void> savePeriodEntry(PeriodEntry entry) async {
    final date = AppDateUtils.dateOnly(entry.date);
    _entries[date] = PeriodEntry(id: entry.id, date: date, flow: entry.flow);
  }

  @override
  Future<void> deletePeriodEntry(DateTime date) async {
    _entries.remove(AppDateUtils.dateOnly(date));
  }

  @override
  Future<void> clear() async => _entries.clear();

  void _seed() {
    const flows = [
      FlowIntensity.medium,
      FlowIntensity.heavy,
      FlowIntensity.medium,
      FlowIntensity.light,
      FlowIntensity.light,
      FlowIntensity.light,
    ];
    final starts = DemoData.periodStarts();
    for (var i = 0; i < starts.length; i++) {
      for (var d = 0; d < DemoData.periodDurations[i]; d++) {
        final date = AppDateUtils.addDays(starts[i], d);
        _entries[date] = PeriodEntry(id: 'seed-period-$i-$d', date: date, flow: flows[d]);
      }
    }
  }
}
