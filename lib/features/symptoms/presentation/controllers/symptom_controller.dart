import 'package:flutter/foundation.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:lunaflow/features/symptoms/domain/entities/ai_insight.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/domain/repositories/symptom_repository.dart';
import 'package:lunaflow/features/symptoms/domain/services/ai_insight_service.dart';

/// State holder for symptoms and the Luna Assistant insight.
class SymptomController extends ChangeNotifier {
  SymptomController({
    required SymptomRepository repository,
    required AiInsightService aiInsightService,
  })  : _repository = repository,
        _aiInsightService = aiInsightService;

  final SymptomRepository _repository;
  final AiInsightService _aiInsightService;

  List<SymptomEntry> _entries = [];
  AiInsight? _insight;
  bool _isGenerating = false;

  List<SymptomEntry> get entries => _entries;
  AiInsight? get insight => _insight;
  bool get isGenerating => _isGenerating;

  List<SymptomEntry> entriesFor(DateTime date) =>
      _entries.where((e) => AppDateUtils.isSameDay(e.date, date)).toList();

  List<SymptomEntry> get todayEntries => entriesFor(AppDateUtils.today());

  bool hasSymptoms(DateTime date) => _entries.any((e) => AppDateUtils.isSameDay(e.date, date));

  /// Symptoms sorted by how often they were logged (most common first).
  List<MapEntry<SymptomType, int>> get topSymptoms {
    final counts = <SymptomType, int>{};
    for (final entry in _entries) {
      counts[entry.type] = (counts[entry.type] ?? 0) + 1;
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<void> load() async {
    _entries = await _repository.getAllEntries();
    notifyListeners();
  }

  /// Saves the symptoms of one day. Intensity 0 means "not present".
  Future<void> saveForDate(DateTime date, Map<SymptomType, int> intensities) async {
    final day = AppDateUtils.dateOnly(date);
    final entries = intensities.entries
        .where((e) => e.value > 0)
        .map((e) => SymptomEntry(
              id: '${day.millisecondsSinceEpoch}-${e.key.name}',
              date: day,
              type: e.key,
              intensity: e.value,
            ))
        .toList();
    await _repository.saveEntriesForDate(day, entries);
    await load();
  }

  Future<void> generateInsight({
    required List<MenstrualCycle> cycles,
    CyclePrediction? prediction,
  }) async {
    _isGenerating = true;
    notifyListeners();
    try {
      _insight = await _aiInsightService.generateInsight(
        symptoms: _entries,
        cycles: cycles,
        prediction: prediction,
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> clearData() async {
    await _repository.clear();
    _insight = null;
    await load();
  }
}
