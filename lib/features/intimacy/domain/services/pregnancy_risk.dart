import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';

enum PregnancyRisk { low, moderate, high }

class IntimacyRiskInfo {
  const IntimacyRiskInfo({
    required this.entry,
    required this.risk,
    required this.inFertileWindow,
    required this.isOvulationDay,
    required this.daysAgo,
  });

  final IntimacyEntry entry;
  final PregnancyRisk risk;
  final bool inFertileWindow;
  final bool isOvulationDay;

  final int daysAgo;

  bool get withinEmergencyWindow => daysAgo >= 0 && daysAgo <= 5;

  bool get needsAttention => risk == PregnancyRisk.high && withinEmergencyWindow;
}

class PregnancyRiskCalculator {
  const PregnancyRiskCalculator();

  IntimacyRiskInfo assess(IntimacyEntry entry, CycleProjection projection, DateTime today) {
    final day = AppDateUtils.dateOnly(entry.date);
    final fertile = projection.fertileDays.contains(day);
    final ovulation = projection.ovulationDays.contains(day);

    final PregnancyRisk risk;
    if (fertile || ovulation) {
      risk = entry.protection.isUnprotected ? PregnancyRisk.high : PregnancyRisk.moderate;
    } else {
      risk = PregnancyRisk.low;
    }

    return IntimacyRiskInfo(
      entry: entry,
      risk: risk,
      inFertileWindow: fertile || ovulation,
      isOvulationDay: ovulation,
      daysAgo: AppDateUtils.daysBetween(day, AppDateUtils.dateOnly(today)),
    );
  }
}
