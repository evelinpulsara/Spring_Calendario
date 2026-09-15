import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:lunaflow/features/cycle/domain/repositories/prediction_repository.dart';
import 'package:lunaflow/features/cycle/domain/services/cycle_calculator.dart';

/// Computes predictions on the device from the stored period entries.
/// A backend-powered version can implement the same interface.
class LocalPredictionRepository implements PredictionRepository {
  LocalPredictionRepository({
    required CycleRepository cycleRepository,
    required CycleCalculator calculator,
  })  : _cycleRepository = cycleRepository,
        _calculator = calculator;

  final CycleRepository _cycleRepository;
  final CycleCalculator _calculator;

  @override
  Future<CyclePrediction?> getPrediction({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  }) async {
    final cycles = _calculator.buildCycles(await _cycleRepository.getPeriodEntries());
    return _calculator.predict(
      cycles: cycles,
      today: AppDateUtils.today(),
      fallbackCycleLength: fallbackCycleLength,
      fallbackPeriodLength: fallbackPeriodLength,
    );
  }

  @override
  Future<CycleProjection> getProjection({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  }) async {
    final cycles = _calculator.buildCycles(await _cycleRepository.getPeriodEntries());
    return _calculator.project(
      cycles: cycles,
      fallbackCycleLength: fallbackCycleLength,
      fallbackPeriodLength: fallbackPeriodLength,
    );
  }
}
