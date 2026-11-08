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
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      final v = details.primaryVelocity ?? 0;
                      if (v < -150) _changeMonth(1);
                      if (v > 150) _changeMonth(-1);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topCenter,
                        children: [...previous, if (current != null) current],
                      ),
                      transitionBuilder: (child, animation) {
                        final incoming = child.key == ValueKey(_visibleMonth);
                        final dx = (incoming ? 0.25 : -0.25) * _direction;
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: GridView.count(
                        key: ValueKey(_visibleMonth),
                        crossAxisCount: 7,
                        childAspectRatio: wide ? 1.3 : 0.8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: cells,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MonthDots(
                    month: _visibleMonth,
                    onPrevious: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            if (wide) _MonthSummary(month: _visibleMonth),
          ],
          sideChildren: [
            const _Legend(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, axisAlignment: -1, child: child),
              ),
              child: _SelectedDayCard(key: ValueKey(_selected), date: _selected),
            ),
          ],
        ),
      ),
    );
  }
}

/// Puntitos con el mes anterior, el actual y el siguiente (se pueden tocar).
class _MonthDots extends StatelessWidget {
  const _MonthDots({required this.month, required this.onPrevious, required this.onNext});

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    Widget dot(DateTime m, bool current, VoidCallback? onTap) => MouseRegion(
          cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: current ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: current ? AppColors.deepPink : AppColors.lavender,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.monthShort(m),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                      color: current ? AppColors.deepPink : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(DateTime(month.year, month.month - 1), false, onPrevious),
        dot(month, true, null),
        dot(DateTime(month.year, month.month + 1), false, onNext),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    this.wide = false,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isPeriod,
    required this.isPredictedPeriod,
    this.isPossibleStart = false,
    this.isExpectedPeriod = false,
    required this.isOvulation,
    required this.isFertile,
    required this.hasSymptoms,
    required this.hasIntimacy,
    this.unprotectedIntimacy = false,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isPeriod;
  final bool isPredictedPeriod;

  /// Posible día de inicio del próximo periodo (ventana de la predicción).
  final bool isPossibleStart;

  /// Día probable del periodo actual, aún sin registrar (rosa opaco).
  final bool isExpectedPeriod;
  final bool isOvulation;
  final bool isFertile;
  final bool hasSymptoms;
  final bool hasIntimacy;

  /// Corazón lleno = sin protección; solo contorno = con protección.
  final bool unprotectedIntimacy;
  final VoidCallback onTap;

  /// true en pantallas grandes (casillas un poco más redondeadas).
  final bool wide;

  @override
  Widget build(BuildContext context) {
    // Relleno de la casilla: periodo registrado, días probables o predicción.
    Color? fill;
    Color? border;
    final onFill = isPeriod || isExpectedPeriod;
    if (isPeriod) {
      fill = AppColors.deepPink;
    } else if (isExpectedPeriod) {
      fill = AppColors.deepPink.withAlpha(90);
    } else if (isPossibleStart) {
      fill = AppColors.softPink.withAlpha(200);
      border = AppColors.deepPink.withAlpha(160);
    } else if (isPredictedPeriod) {
      fill = AppColors.softPink.withAlpha(120);
    }

    // Color del número: verde (normal), morado (ventana fértil / ovulación).
    final Color numberColor;
    if (onFill) {
      numberColor = Colors.white;
    } else if (isPossibleStart || isPredictedPeriod) {
      numberColor = AppColors.deepPink;
    } else if (isOvulation || isFertile) {
      numberColor = AppColors.purple;
    } else {
      numberColor = AppColors.normalDay;
    }
    final markerColor = onFill ? Colors.white : null;
    final radius = BorderRadius.circular(wide ? 14 : 12);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.06 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.all(wide ? 3 : 2),
            decoration: BoxDecoration(
              color: fill ?? Colors.transparent,
              borderRadius: radius,
              border: Border.all(
                color: isToday
                    ? AppColors.deepPurple
                    : isSelected
                        ? AppColors.purple
                        : (border ?? Colors.transparent),
                width: isToday || isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.purple.withAlpha(60), blurRadius: 10)]
                  : null,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Marcadores arriba del número: ovulación, relación, síntomas.
                      SizedBox(
                        height: 14,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOvulation)
                              Icon(Icons.local_florist_rounded,
                                  size: 13, color: markerColor ?? AppColors.purple),
                            if (isOvulation && hasIntimacy) const SizedBox(width: 2),
                            if (hasIntimacy)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.elasticOut,
                                builder: (context, v, child) =>
                                    Transform.scale(scale: v, child: child),
                                child: _HeartMarker(
                                  filled: unprotectedIntimacy,
                                  color: markerColor ?? AppColors.deepPink,
                                ),
                              ),
                            if ((isOvulation || hasIntimacy) && hasSymptoms)
                              const SizedBox(width: 2),
                            if (hasSymptoms)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: markerColor ?? AppColors.deepPurple,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '$day',
                        style: TextStyle(
                          color: numberColor,
                          fontSize: 16,
                          height: 1.15,
                          fontWeight: isPeriod || isToday ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                        child: isToday
                            ? Text(
                                AppLanguage.tr('Hoy', 'Today'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: onFill ? Colors.white : AppColors.deepPurple,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Resumen del mes visible (solo en computadora, debajo del calendario).
class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cycle = context.watch<CycleController>();
    final symptoms = context.watch<SymptomController>();
    final intimacy = context.watch<IntimacyController>();
    final days = DateTime(month.year, month.month + 1, 0).day;

    var period = 0, withSymptoms = 0, fertile = 0, relations = 0;
    for (var d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      if (cycle.isPeriodDay(date)) period++;
      if (symptoms.hasSymptoms(date)) withSymptoms++;
      if (cycle.projection.fertileDays.contains(date)) fertile++;
      if (intimacy.hasEntry(date)) relations++;
    }

    Widget tile(IconData icon, Color color, int value, String label) => Expanded(
          child: SpringCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withAlpha(35), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey('$month-$label'),
                        tween: Tween(begin: 0, end: value.toDouble()),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Text('${v.round()}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          tile(Icons.water_drop_rounded, AppColors.deepPink, period,
              t.isSpanish ? 'Días de menstruación' : 'Period days'),
          const SizedBox(width: 12),
          tile(Icons.spa_rounded, AppColors.purple, fertile,
              t.isSpanish ? 'Días fértiles (estimado)' : 'Fertile days (estimate)'),
          const SizedBox(width: 12),
          tile(Icons.edit_note_rounded, AppColors.deepPurple, withSymptoms,
              t.isSpanish ? 'Días con síntomas' : 'Days with symptoms'),
          const SizedBox(width: 12),
          tile(Icons.favorite_rounded, AppColors.deepPink, relations,
              t.isSpanish ? 'Relaciones registradas' : 'Logged intimacy'),
        ],
      ),
    );
  }
}

/// Corazón de relación sexual: lleno = sin protección; contorno grueso = con protección.
class _HeartMarker extends StatelessWidget {
  const _HeartMarker({required this.filled, this.color = AppColors.deepPink, this.size = 13});

  final bool filled;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      size: size,
      color: color,
      weight: 700,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final es = t.isSpanish;

    Widget item(Widget marker, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 18, child: Center(child: marker)),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 12))),
          ],
        );

    // Cuadrito redondeado como las casillas del calendario.
    Widget box({Color? fill, Color? border}) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: fill,
            border: border != null ? Border.all(color: border, width: 1.5) : null,
          ),
        );

    // Número de ejemplo con el color del tipo de día.
    Widget number(Color color) =>
