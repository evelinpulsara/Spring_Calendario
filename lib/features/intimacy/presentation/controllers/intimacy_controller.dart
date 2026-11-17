import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';

class IntimacyController extends ChangeNotifier {
  IntimacyController({
    required IntimacyRepository repository,
    PregnancyRiskCalculator riskCalculator = const PregnancyRiskCalculator(),
  })  : _repository = repository,
        _riskCalculator = riskCalculator;

  final IntimacyRepository _repository;
  final PregnancyRiskCalculator _riskCalculator;
  final Map<DateTime, IntimacyEntry> _byDate = {};

  List<IntimacyEntry> get entries =>
      _byDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  IntimacyEntry? entryFor(DateTime date) => _byDate[AppDateUtils.dateOnly(date)];

  bool hasEntry(DateTime date) => _byDate.containsKey(AppDateUtils.dateOnly(date));

  Future<void> load() async {
    final all = await _repository.getAll();
    _byDate
      ..clear()
      ..addEntries(all.map((e) => MapEntry(AppDateUtils.dateOnly(e.date), e)));
    notifyListeners();
  }

  Future<void> save(DateTime date, ProtectionType protection) async {
    final day = AppDateUtils.dateOnly(date);
    await _repository.save(IntimacyEntry(
      id: 'intimacy-${day.millisecondsSinceEpoch}',
      date: day,
      protection: protection,
    ));
    await load();
  }

  Future<void> remove(DateTime date) async {
    await _repository.deleteForDate(date);
    await load();
  }

  Future<void> clearData() async {
    await _repository.clear();
    await load();
  }

  IntimacyRiskInfo? riskFor(DateTime date, CycleProjection projection) {
    final entry = entryFor(date);
    if (entry == null) return null;
    return _riskCalculator.assess(entry, projection, AppDateUtils.today());
  }

  List<IntimacyRiskInfo> riskReport(CycleProjection projection) {
    final today = AppDateUtils.today();
    return entries.reversed
        .map((e) => _riskCalculator.assess(e, projection, today))
        .toList();
  }

  IntimacyRiskInfo? urgentRisk(CycleProjection projection) {
    for (final info in riskReport(projection)) {
      if (info.needsAttention) return info;
    }
    return null;
  }
}
