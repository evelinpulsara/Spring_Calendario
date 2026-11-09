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
    if (_flow != FlowIntensity.none) {
      await cycle.setPeriodDay(_date, flow: _flow);
    } else if (cycle.isPeriodDay(_date)) {
      await cycle.removePeriodDay(_date);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(t.isSpanish
            ? 'Guardado para el ${AppDateUtils.shortDate(_date)}'
            : 'Saved for ${AppDateUtils.shortDate(_date)}'),
      ),
    );
    if (widget.isStandalone && mounted) navigator.pop();
  }

  String _symptomLabel(SymptomType type, AppLocalizations t) {
    switch (type) {
      case SymptomType.cramps:
        return t.cramps;
      case SymptomType.headache:
        return t.headache;
      case SymptomType.mood:
        return t.mood;
      case SymptomType.bloating:
        return t.bloating;
      case SymptomType.acne:
        return t.acne;
      case SymptomType.fatigue:
        return t.fatigue;
      case SymptomType.appetite:
        return t.appetite;
      case SymptomType.sleep:
        return t.sleep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isToday = AppDateUtils.isSameDay(_date, AppDateUtils.today());
    final wide = Breakpoints.isWide(context);
    final dateCard = SpringCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _changeDate(AppDateUtils.addDays(_date, -1)),
          ),
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(isToday ? t.today : AppDateUtils.longDate(_date)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: isToday ? null : () => _changeDate(AppDateUtils.addDays(_date, 1)),
          ),
        ],
      ),
    );
    final flowCard = SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(t.isSpanish ? 'Intensidad del flujo' : 'Flow intensity'),
          Wrap(
            spacing: 8,
            children: [
              for (final flow in FlowIntensity.values)
                ChoiceChip(
                  label: Text(flow.label),
                  selected: _flow == flow,
                  selectedColor: AppColors.softPink,
                  onSelected: (_) => setState(() => _flow = flow),
                ),
            ],
          ),
        ],
      ),
    );
    final symptomsCard = SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(t.isSpanish ? 'Síntomas' : 'Symptoms'),
          Text(
            t.isSpanish
                ? 'Toca un punto para indicar su intensidad (1-5). Tócalo de nuevo para borrarlo.'
