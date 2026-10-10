import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';

/// Estado de las relaciones registradas y su riesgo estimado.
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

