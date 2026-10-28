import 'package:flutter_test/flutter_test.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/features/cycle/domain/services/cycle_calculator.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_guidance.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';

void main() {
  const calculator = PregnancyRiskCalculator();
  final ovulation = DateTime(2026, 10, 14);
  final projection = CycleProjection(
    predictedPeriodDays: const {},
    fertileDays: {
      for (var d = -5; d <= 1; d++) DateTime(2026, 10, 14 + d),
    },
    ovulationDays: {ovulation},
  );
  final today = DateTime(2026, 10, 16);

  IntimacyEntry entry(DateTime date, ProtectionType p) =>
      IntimacyEntry(id: 'x', date: date, protection: p);

  setUp(() => AppLanguage.isSpanish = true);

  test('sin protección en la ovulación es riesgo alto y aún a tiempo', () {
    final info = calculator.assess(entry(ovulation, ProtectionType.none), projection, today);
    expect(info.risk, PregnancyRisk.high);
    expect(info.isOvulationDay, isTrue);
    expect(info.daysAgo, 2);
    expect(info.needsAttention, isTrue);
    expect(PregnancyGuidance.message(info), contains('pastilla anticonceptiva de emergencia'));
  });

  test('"no estoy segura" se trata como sin protección', () {
    final info = calculator.assess(
        entry(DateTime(2026, 10, 10), ProtectionType.unsure), projection, today);
    expect(info.risk, PregnancyRisk.high);
  });

  test('con condón en días fértiles es riesgo moderado', () {
    final info =
        calculator.assess(entry(DateTime(2026, 10, 12), ProtectionType.condom), projection, today);
    expect(info.risk, PregnancyRisk.moderate);
    expect(info.needsAttention, isFalse);
  });

  test('fuera de la ventana fértil es riesgo bajo', () {
    final info =
        calculator.assess(entry(DateTime(2026, 10, 2), ProtectionType.none), projection, today);
    expect(info.risk, PregnancyRisk.low);
    expect(info.inFertileWindow, isFalse);
  });

  test('después de 5 días ya no está a tiempo de la pastilla', () {
    final info = calculator.assess(
        entry(ovulation, ProtectionType.none), projection, DateTime(2026, 10, 21));
    expect(info.risk, PregnancyRisk.high);
    expect(info.withinEmergencyWindow, isFalse);
    expect(PregnancyGuidance.message(info), contains('más de 5 días'));
  });
}
