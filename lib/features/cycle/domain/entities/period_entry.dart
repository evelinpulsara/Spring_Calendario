import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';

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
