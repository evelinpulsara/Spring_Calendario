import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';
import 'package:lunaflow/shared/widgets/section_title.dart';

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
      SnackBar(content: Text('Saved for ${AppDateUtils.shortDate(_date)}')),
    );
    if (widget.isStandalone && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = AppDateUtils.isSameDay(_date, AppDateUtils.today());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log symptoms'),
        automaticallyImplyLeading: widget.isStandalone,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            LunarCard(
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
                    label: Text(isToday ? 'Today' : AppDateUtils.longDate(_date)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed:
                        isToday ? null : () => _changeDate(AppDateUtils.addDays(_date, 1)),
                  ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Flow intensity'),
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
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Symptoms'),
                  const Text('Tap a dot to set how strong it is (1-5). Tap it again to clear.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  for (final type in SymptomType.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(type.icon, color: AppColors.purple),
                          const SizedBox(width: 12),
                          Expanded(child: Text(type.label)),
                          _IntensitySelector(
                            value: _levels[type] ?? 0,
                            onChanged: (value) => setState(() {
                              if (value == 0) {
                                _levels.remove(type);
                              } else {
                                _levels[type] = value;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntensitySelector extends StatelessWidget {
  const _IntensitySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final level = index + 1;
        final filled = level <= value;
        return GestureDetector(
          onTap: () => onChanged(level == value ? 0 : level),
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.purple : Colors.transparent,
              border: Border.all(color: AppColors.purple.withAlpha(filled ? 255 : 110), width: 1.5),
            ),
          ),
        );
      }),
    );
  }
}
