import 'package:lunaflow/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:lunaflow/features/cycle/domain/services/cycle_calculator.dart';

/// Contract for predictions. It can be computed locally or by a backend.
abstract class PredictionRepository {
  /// Returns `null` when there is not enough data (no period logged yet).
  Future<CyclePrediction?> getPrediction({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  });

  Future<CycleProjection> getProjection({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  });
}
