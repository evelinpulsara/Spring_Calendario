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
                : 'Tap a dot to set how strong it is (1-5). Tap it again to clear.',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          _SymptomGrid(
            columns: wide ? 2 : 1,
            children: [
              for (final type in SymptomType.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(type.icon, color: AppColors.purple),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_symptomLabel(type, t))),
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
        ],
      ),
    );
    final saveButton = ElevatedButton.icon(
      onPressed: _save,
      icon: const Icon(Icons.check_rounded),
      label: Text(t.isSpanish ? 'Guardar' : 'Save'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(t.logSymptomsTitle),
        automaticallyImplyLeading: widget.isStandalone,
      ),
      body: SafeArea(
        child: wide
            ? StaggeredListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [dateCard, symptomsCard],
                sideChildren: [flowCard, _DaySummaryCard(flow: _flow, levels: _levels), saveButton],
              )
            : StaggeredListView(
                maxWidth: 760,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [dateCard, flowCard, symptomsCard, saveButton],
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

/// Lista de síntomas: una columna en celular, dos en computadora.
class _SymptomGrid extends StatelessWidget {
  const _SymptomGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columns == 1) return Column(children: children);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.lavenderSoft : AppColors.night,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: child,
              ),
          ],
        );
      },
    );
  }
}

/// Resumen de lo que se va a guardar (solo en computadora).
class _DaySummaryCard extends StatelessWidget {
  const _DaySummaryCard({required this.flow, required this.levels});

  final FlowIntensity flow;
  final Map<SymptomType, int> levels;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final selected = levels.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(t.isSpanish ? 'Resumen del día' : 'Day summary'),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 18, color: AppColors.deepPink),
              const SizedBox(width: 8),
              Text('${t.isSpanish ? 'Flujo' : 'Flow'}: ${flow.label}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: selected.isEmpty
                ? Text(
                    t.isSpanish
                        ? 'Aún no marcaste síntomas para este día.'
                        : 'No symptoms selected for this day yet.',
                    key: const ValueKey('none'),
                    style: const TextStyle(color: AppColors.textMuted),
                  )
                : Wrap(
                    key: ValueKey(selected.length),
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in selected)
                        Chip(
                          avatar: Icon(e.key.icon, size: 16, color: AppColors.purple),
                          label: Text('${e.key.label} ${e.value}/5'),
                          backgroundColor: AppColors.purple.withAlpha(35),
                          side: BorderSide.none,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
