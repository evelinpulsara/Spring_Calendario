import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/l10n/app_localizations.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/utils/date_utils.dart';
import 'package:lunaflow/features/cycle/domain/entities/flow_intensity.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/domain/entities/symptom_type.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:lunaflow/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';

/// Monthly calendar with period days, predictions, fertile window and symptoms.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = AppDateUtils.today();

  void _changeMonth(int delta) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final projection = cycle.projection;
    final today = AppDateUtils.today();

    final firstDay = _visibleMonth;
    final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;

    // Day-of-week headers translated
    final weekDays = t.isSpanish
        ? ['L', 'M', 'X', 'J', 'V', 'S', 'D']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        Builder(builder: (context) {
          final date = DateTime(firstDay.year, firstDay.month, day);
          final isPeriod = cycle.isPeriodDay(date);
          return _DayCell(
            day: day,
            isToday: AppDateUtils.isSameDay(date, today),
            isSelected: AppDateUtils.isSameDay(date, _selected),
            isPeriod: isPeriod,
            isPredictedPeriod: !isPeriod && projection.predictedPeriodDays.contains(date),
            isOvulation: projection.ovulationDays.contains(date),
            isFertile: projection.fertileDays.contains(date),
            hasSymptoms: symptoms.hasSymptoms(date),
            onTap: () => setState(() => _selected = date),
          );
        }),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.calendar)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            LunarCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => _changeMonth(-1)),
                      Text(AppDateUtils.monthYear(_visibleMonth),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => _changeMonth(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final label in weekDays)
                        Expanded(
                          child: Center(
                            child: Text(label,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: cells,
                  ),
                ],
              ),
            ),
            _Legend(),
            _SelectedDayCard(date: _selected),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isPeriod,
    required this.isPredictedPeriod,
    required this.isOvulation,
    required this.isFertile,
    required this.hasSymptoms,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isPeriod;
  final bool isPredictedPeriod;
  final bool isOvulation;
  final bool isFertile;
  final bool hasSymptoms;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? fill;
    Color? border;
    var textColor = Theme.of(context).colorScheme.onSurface;

    if (isPeriod) {
      fill = AppColors.deepPink;
      textColor = Colors.white;
    } else if (isOvulation) {
      fill = AppColors.purple;
      textColor = Colors.white;
    } else if (isPredictedPeriod) {
      border = AppColors.deepPink;
    } else if (isFertile) {
      fill = AppColors.purple.withAlpha(45);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.deepPurple, width: 2) : null,
        ),
        child: Container(
          margin: EdgeInsets.all(isSelected ? 2 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: border != null ? Border.all(color: border, width: 1.5) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                  decoration: isToday ? TextDecoration.underline : null,
                ),
              ),
              if (hasSymptoms)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isPeriod || isOvulation) ? Colors.white : AppColors.deepPurple,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget item(Widget marker, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [marker, const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12))],
        );

    Widget dot({Color? fill, Color? border}) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: border != null ? Border.all(color: border, width: 1.5) : null,
          ),
        );

    return LunarCard(
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          item(dot(fill: AppColors.deepPink), t.periodDays),
          item(dot(border: AppColors.deepPink), t.predicted),
          item(dot(fill: AppColors.purple.withAlpha(45)), t.fertile),
          item(dot(fill: AppColors.purple), t.isSpanish ? 'Ovulación' : 'Ovulation'),
          item(
            Container(
                width: 6,
                height: 6,
                decoration:
                    const BoxDecoration(shape: BoxShape.circle, color: AppColors.deepPurple)),
            t.isSpanish ? 'Síntomas' : 'Symptoms',
          ),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final projection = cycle.projection;
    final isFuture = date.isAfter(AppDateUtils.today());
    final flow = cycle.flowFor(date);
    final entries = symptoms.entriesFor(date);

    final status = <String>[
      if (flow != null)
        t.isSpanish
            ? 'Día de menstruación (flujo ${flow.label.toLowerCase()})'
            : 'Period day (${flow.label.toLowerCase()} flow)',
      if (flow == null && projection.predictedPeriodDays.contains(date))
        t.isSpanish ? 'Menstruación predicha' : 'Predicted period',
      if (projection.ovulationDays.contains(date))
        t.isSpanish ? 'Día de ovulación estimado' : 'Estimated ovulation day',
      if (projection.fertileDays.contains(date) && !projection.ovulationDays.contains(date))
        t.isSpanish ? 'Ventana fértil (estimado)' : 'Fertile window (estimate)',
    ];

    return LunarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppDateUtils.longDate(date),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (status.isEmpty && entries.isEmpty)
            Text(t.isSpanish ? 'Nada registrado para este día.' : 'Nothing recorded for this day.',
                style: const TextStyle(color: AppColors.textMuted)),
          for (final line in status) Text(line),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in entries)
                  Chip(
                    avatar: Icon(entry.type.icon, size: 16, color: AppColors.purple),
                    label: Text('${entry.type.label} ${entry.intensity}/5'),
                    backgroundColor: AppColors.purple.withAlpha(35),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isFuture ? null : () => cycle.togglePeriodDay(date),
              icon: Icon(cycle.isPeriodDay(date) ? Icons.close_rounded : Icons.water_drop_rounded),
              label: Text(cycle.isPeriodDay(date)
                  ? (t.isSpanish ? 'Quitar marca de menstruación' : 'Remove period mark')
                  : (t.isSpanish ? 'Marcar como día de menstruación' : 'Mark as period day')),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isFuture
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        AppRoutes.logSymptoms,
                        arguments: LogSymptomsArgs(initialDate: date),
                      ),
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(t.isSpanish
                  ? 'Registrar síntomas de este día'
                  : 'Log symptoms for this day'),
            ),
          ),
          if (isFuture)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  t.isSpanish
                      ? 'Solo puedes registrar hoy o días pasados.'
                      : 'You can only log today or past days.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
        ],
      ),
    );
  }
}
