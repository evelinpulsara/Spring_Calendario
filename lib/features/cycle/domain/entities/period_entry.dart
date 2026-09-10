import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';

/// One logged day of menstrual bleeding.
class PeriodEntry {
  const PeriodEntry({
    required this.id,
    required this.date,
    this.flow = FlowIntensity.medium,
  });

  final String id;
  final DateTime date;
  final FlowIntensity flow;
}
