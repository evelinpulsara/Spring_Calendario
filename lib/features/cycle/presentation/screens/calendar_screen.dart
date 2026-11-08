import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/intimacy_sheet.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/intimacy_visuals.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/pregnancy_risk_card.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/screens/log_symptoms_screen.dart';
import 'package:spring_calendario/features/symptoms/presentation/widgets/symptom_visuals.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

/// Monthly calendar with period days, predictions, fertile window and symptoms.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = AppDateUtils.today();
  int _direction = 1;

  void _goToToday() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month);
    setState(() {
      _direction = target.isBefore(_visibleMonth) ? -1 : 1;
      _visibleMonth = target;
      _selected = AppDateUtils.today();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _direction = delta;
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final intimacy = context.watch<IntimacyController>();
    final projection = cycle.projection;
    final today = AppDateUtils.today();
    // En computadora: casillas rectangulares, estilo calendario web.
    final wide = Breakpoints.isWide(context);

    final isCurrentMonth = _visibleMonth.year == today.year && _visibleMonth.month == today.month;
    final firstDay = _visibleMonth;
    final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;

    // Day-of-week headers translated
    final weekDays =
        t.isSpanish ? ['L', 'M', 'X', 'J', 'V', 'S', 'D'] : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        Builder(builder: (context) {
          final date = DateTime(firstDay.year, firstDay.month, day);
          final isPeriod = cycle.isPeriodDay(date);
          return _DayCell(
            wide: wide,
            day: day,
            isToday: AppDateUtils.isSameDay(date, today),
            isSelected: AppDateUtils.isSameDay(date, _selected),
            isPeriod: isPeriod,
            isPredictedPeriod: !isPeriod && projection.predictedPeriodDays.contains(date),
            isPossibleStart: !isPeriod && projection.possibleStartDays.contains(date),
            isExpectedPeriod: !isPeriod && projection.expectedPeriodDays.contains(date),
            isOvulation: projection.ovulationDays.contains(date),
            isFertile: projection.fertileDays.contains(date),
            hasSymptoms: symptoms.hasSymptoms(date),
            hasIntimacy: intimacy.hasEntry(date),
            unprotectedIntimacy: intimacy.entryFor(date)?.protection.isUnprotected ?? false,
            onTap: () => setState(() => _selected = date),
          );
        }),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.calendar)),
      body: SafeArea(
        child: StaggeredListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SpringCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => _changeMonth(-1)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                                child: child,
                              ),
                            ),
                            child: Text(AppDateUtils.monthYear(_visibleMonth),
                                key: ValueKey(_visibleMonth),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => _changeMonth(1)),
                    ],
                  ),
                  // "Volver a hoy" cuando se está viendo otro mes.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: isCurrentMonth
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ActionChip(
                              avatar: const Icon(Icons.today_rounded, size: 16),
                              label: Text(t.isSpanish ? 'Volver a hoy' : 'Back to today'),
                              onPressed: _goToToday,
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final label in weekDays)
                        Expanded(
                          child: Center(
                            child: Text(label,
