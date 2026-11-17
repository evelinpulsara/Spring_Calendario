import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/menstrual_cycle.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_forecast.dart';
import 'package:spring_calendario/features/cycle/data/services/local_period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/domain/services/period_forecast_service.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/prediction_repository.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';

class CycleController extends ChangeNotifier {
  CycleController({
    required CycleRepository cycleRepository,
    required PredictionRepository predictionRepository,
    required CycleCalculator calculator,
    required User? Function() currentUser,
    PeriodForecastService forecastService = const LocalPeriodForecastService(),
  })  : _cycleRepository = cycleRepository,
        _predictionRepository = predictionRepository,
        _calculator = calculator,
        _currentUser = currentUser,
        _forecastService = forecastService;

  final CycleRepository _cycleRepository;
  final PredictionRepository _predictionRepository;
  final CycleCalculator _calculator;
  final User? Function() _currentUser;
  final PeriodForecastService _forecastService;

  PeriodForecast? _forecast;
  String? _forecastKey;
  bool _isForecasting = false;
  int _forecastRequest = 0;

  final Map<DateTime, PeriodEntry> _entriesByDate = {};
  List<MenstrualCycle> _cycles = [];
  CyclePrediction? _prediction;
  CycleProjection _projection = CycleProjection.empty;

  List<MenstrualCycle> get cycles => _cycles;

  List<PeriodEntry> get periodEntries =>
      _entriesByDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  CyclePrediction? get prediction => _prediction;
  CycleProjection get projection => _projection;

  PeriodForecast? get forecast => _forecast;

  bool get isForecasting => _isForecasting;

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

    final input = _forecastInput(user, cycleLength, periodLength);
    if (input == null) {
      _forecast = null;
      _forecastKey = null;
    } else if (input.cacheKey == _forecastKey && _forecast != null) {
      _applyForecast(cycleLength, periodLength);
    } else {
      _forecast = await const LocalPeriodForecastService().forecast(input);
      _forecastKey = null;
      _applyForecast(cycleLength, periodLength);
      _requestForecast(input, cycleLength, periodLength);
    }
    notifyListeners();
  }

  Future<void> refreshForecast() async {
    final user = _currentUser();
    final cycleLength = user?.averageCycleLength ?? AppConstants.defaultCycleLength;
    final periodLength = user?.averagePeriodDuration ?? AppConstants.defaultPeriodDuration;
    final input = _forecastInput(user, cycleLength, periodLength);
    if (input == null) return;
    await _requestForecast(input, cycleLength, periodLength);
  }

  ForecastInput? _forecastInput(User? user, int cycleLength, int periodLength) {
    final baseline = _calculator.predict(
      cycles: _cycles,
      today: AppDateUtils.today(),
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
    );
    if (baseline == null) return null;
    return ForecastInput(
      today: AppDateUtils.today(),
      ageGroup: user?.ageGroup ?? AgeGroup.unknown,
      regularity: user?.regularity ?? CycleRegularity.unsure,
      typicalPeriodLength: periodLength,
      typicalCycleLength: cycleLength,
      cycles: _cycles,
      baseline: baseline,
    );
  }

  Future<void> _requestForecast(ForecastInput input, int cycleLength, int periodLength) async {
    final request = ++_forecastRequest;
    _isForecasting = true;
    notifyListeners();
    try {
      final result = await _forecastService.forecast(input);
      if (request != _forecastRequest) return;
      _forecast = result;
      _forecastKey = input.cacheKey;
      _applyForecast(cycleLength, periodLength);
    } finally {
      if (request == _forecastRequest) {
        _isForecasting = false;
        notifyListeners();
      }
    }
  }

  void _applyForecast(int cycleLength, int periodLength) {
    final f = _forecast;
    if (f == null) return;
    final override = PredictionOverride(
      earliestStart: f.earliestStart,
      likelyStart: f.likelyStart,
      latestStart: f.latestStart,
      periodLength: f.periodLength,
      ovulationDate: f.ovulationDate,
    );
    _prediction = _calculator.predict(
      cycles: _cycles,
      today: AppDateUtils.today(),
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
      override: override,
    );
    _projection = _calculator.project(
      cycles: _cycles,
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
      override: override,
    );
  }

  Future<void> addPeriodDays(DateTime start, int days) async {
    final today = AppDateUtils.today();
    for (var d = 0; d < days; d++) {
      final day = AppDateUtils.addDays(AppDateUtils.dateOnly(start), d);
      if (day.isAfter(today)) break;
      if (isPeriodDay(day)) continue;
      await _cycleRepository.savePeriodEntry(PeriodEntry(
        id: 'period-${day.millisecondsSinceEpoch}',
        date: day,
        flow: FlowIntensity.medium,
      ));
    }
    await load();
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
