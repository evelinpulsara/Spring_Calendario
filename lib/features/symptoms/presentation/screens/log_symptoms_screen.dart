import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';
import 'package:spring_calendario/shared/widgets/section_title.dart';

/// Arguments for opening the log screen as a separate route.
class LogSymptomsArgs {
  const LogSymptomsArgs({this.initialDate, this.preselected});
  final DateTime? initialDate;
  final SymptomType? preselected;
}

/// Lets the user record flow intensity and symptoms for a given day.
class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({
    super.key,
    this.initialDate,
    this.preselected,
    this.isStandalone = false,
  });

  final DateTime? initialDate;
  final SymptomType? preselected;

  /// True when opened with Navigator.push (shows a back button, closes on save).
  final bool isStandalone;

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  late DateTime _date;
  FlowIntensity _flow = FlowIntensity.none;
  final Map<SymptomType, int> _levels = {};

  @override
  void initState() {
    super.initState();
    _date = AppDateUtils.dateOnly(widget.initialDate ?? DateTime.now());
    _loadDay();
    final preselected = widget.preselected;
    if (preselected != null && !_levels.containsKey(preselected)) {
      _levels[preselected] = 3;
    }
  }

  void _loadDay() {
    final symptoms = context.read<SymptomController>();
    final cycle = context.read<CycleController>();
    _levels
      ..clear()
      ..addEntries(symptoms.entriesFor(_date).map((e) => MapEntry(e.type, e.intensity)));
    _flow = cycle.flowFor(_date) ?? FlowIntensity.none;
  }

  void _changeDate(DateTime date) {
    setState(() {
      _date = AppDateUtils.dateOnly(date);
      _loadDay();
    });
  }

  Future<void> _pickDate() async {
    final today = AppDateUtils.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: AppDateUtils.addDays(today, -365),
      lastDate: today,
    );
    if (picked != null) _changeDate(picked);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final symptoms = context.read<SymptomController>();
    final cycle = context.read<CycleController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await symptoms.saveForDate(_date, _levels);
