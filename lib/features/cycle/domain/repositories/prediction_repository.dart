import 'package:spring_calendario/features/cycle/domain/entities/cycle_prediction.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';

abstract class PredictionRepository {
  Future<CyclePrediction?> getPrediction({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  });

  Future<CycleProjection> getProjection({
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  });
}
