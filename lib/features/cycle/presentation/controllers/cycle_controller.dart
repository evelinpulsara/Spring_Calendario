import 'package:flutter/foundation.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/authentication/domain/entities/user.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';
import 'package:lunaflow/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:lunaflow/features/cycle/domain/entities/period_entry.dart';
import 'package:lunaflow/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:lunaflow/features/cycle/domain/repositories/prediction_repository.dart';
import 'package:lunaflow/features/cycle/domain/services/cycle_calculator.dart';

/// State holder for period days, derived cycles and predictions.
class CycleController extends ChangeNotifier {
  CycleController({
    required CycleRepository cycleRepository,
    required PredictionRepository predictionRepository,
    required CycleCalculator calculator,
    required User? Function() currentUser,
  })  : _cycleRepository = cycleRepository,
        _predictionRepository = predictionRepository,
        _calculator = calculator,
        _currentUser = currentUser;

  final CycleRepository _cycleRepository;
  final PredictionRepository _predictionRepository;
  final CycleCalculator _calculator;
  final User? Function() _currentUser;

  final Map<DateTime, PeriodEntry> _entriesByDate = {};
  List<MenstrualCycle> _cycles = [];
  CyclePrediction? _prediction;
  CycleProjection _projection = CycleProjection.empty;

  List<MenstrualCycle> get cycles => _cycles;
  CyclePrediction? get prediction => _prediction;
  CycleProjection get projection => _projection;

  /// Most recent cycles first.
  List<MenstrualCycle> get recentCycles => _cycles.reversed.take(6).toList();

  double? get averageCycleLength => _calculator.averageCycleLength(_cycles);
  double? get averagePeriodLength => _calculator.averagePeriodLength(_cycles);

  bool isPeriodDay(DateTime date) => _entriesByDate.containsKey(AppDateUtils.dateOnly(date));

  FlowIntensity? flowFor(DateTime date) => _entriesByDate[AppDateUtils.dateOnly(date)]?.flow;

  Future<void> load() async {
    final user = _currentUser();
    final cycleLength = user?.averageCycleLength ?? AppConstants.defaultCycleLength;
    final periodLength = user?.averagePeriodDuration ?? AppConstants.defaultPeriodDuration;

    final entries = await _cycleRepository.getPeriodEntries();
    _entriesByDate
      ..clear()
      ..addEntries(entries.map((e) => MapEntry(AppDateUtils.dateOnly(e.date), e)));
    _cycles = _calculator.buildCycles(entries);
    _prediction = await _predictionRepository.getPrediction(
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
    );
    _projection = await _predictionRepository.getProjection(
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
    );
    notifyListeners();
  }

  Future<void> setPeriodDay(DateTime date, {FlowIntensity flow = FlowIntensity.medium}) async {
    final day = AppDateUtils.dateOnly(date);
    await _cycleRepository.savePeriodEntry(PeriodEntry(
      id: 'period-${day.millisecondsSinceEpoch}',
      date: day,
      flow: flow,
    ));
    await load();
  }

  Future<void> removePeriodDay(DateTime date) async {
    await _cycleRepository.deletePeriodEntry(date);
    await load();
  }

  Future<void> togglePeriodDay(DateTime date) {
    return isPeriodDay(date) ? removePeriodDay(date) : setPeriodDay(date);
  }

  Future<void> clearData() async {
    await _cycleRepository.clear();
    await load();
  }
}
