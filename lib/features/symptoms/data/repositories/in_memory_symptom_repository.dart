import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/constants/demo_data.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/domain/repositories/symptom_repository.dart';

/// Stores symptoms in memory. Replace with a database/API version later.
class InMemorySymptomRepository implements SymptomRepository {
  InMemorySymptomRepository() {
    if (AppConstants.seedDemoData) _seed();
  }

  final List<SymptomEntry> _entries = [];
  int _seedCounter = 0;

  @override
  Future<List<SymptomEntry>> getAllEntries() async => List.unmodifiable(_entries);

  @override
  Future<void> saveEntriesForDate(DateTime date, List<SymptomEntry> entries) async {
    _entries.removeWhere((e) => AppDateUtils.isSameDay(e.date, date));
    _entries.addAll(entries);
  }

  @override
  Future<void> clear() async => _entries.clear();

  void _add(DateTime date, SymptomType type, int intensity) {
    _entries.add(SymptomEntry(
      id: 'seed-symptom-${_seedCounter++}',
      date: AppDateUtils.dateOnly(date),
      type: type,
      intensity: intensity,
    ));
  }

  /// Demo pattern: bloating + fatigue just before each period, cramps during it.
  void _seed() {
    final starts = DemoData.periodStarts(); // newest first
    for (var i = 0; i < starts.length; i++) {
      _add(starts[i], SymptomType.cramps, 4);
      _add(AppDateUtils.addDays(starts[i], 1), SymptomType.cramps, 3);
      if (i > 0) {
        for (var d = 1; d <= 4; d++) {
          final date = AppDateUtils.addDays(starts[i - 1], -d);
          _add(date, SymptomType.bloating, 3);
          _add(date, SymptomType.fatigue, 3);
        }
        if (i.isEven) _add(AppDateUtils.addDays(starts[i - 1], -2), SymptomType.headache, 2);
      }
    }
    final today = AppDateUtils.today();
    _add(today, SymptomType.mood, 4);
    _add(today, SymptomType.sleep, 3);
  }
}
