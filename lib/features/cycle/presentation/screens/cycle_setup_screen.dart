import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/moon_widget.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

/// Cuestionario inicial: edad, duración del periodo, duración del ciclo,
/// regularidad y fecha de la última menstruación. Con esto la IA hace la
/// primera predicción.
///
/// Rangos de referencia (ACOG): adolescentes, ciclos de 21–45 días;
/// adultas, 24–38 días; el sangrado suele durar hasta 7 días.
class CycleSetupScreen extends StatefulWidget {
  const CycleSetupScreen({super.key, this.isEditing = false});

  /// true cuando se abre desde Perfil para actualizar los datos.
  final bool isEditing;

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen> {
  static const int _steps = 5;

  final PageController _pages = PageController();
  int _step = 0;
  bool _saving = false;

  late AgeGroup _ageGroup;
  late int _periodLength;
  late int _cycleLength;
  bool _cycleUnknown = false;
  late CycleRegularity _regularity;
  DateTime? _lastStart;
  bool _lastStartUnknown = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionController>().user;
    final cycles = context.read<CycleController>().cycles;
    _ageGroup = user?.ageGroup ?? AgeGroup.unknown;
    _periodLength = (user?.averagePeriodDuration ?? 5).clamp(1, 10);
    _cycleLength = (user?.averageCycleLength ?? 28).clamp(20, 45);
    _regularity = user?.regularity ?? CycleRegularity.unsure;
    _lastStart = cycles.isEmpty ? null : cycles.last.startDate;
    // Si aún no se cargaron los periodos registrados, cargarlos para sugerir la fecha.
    if (cycles.isEmpty) {
      context.read<CycleController>().load().then((_) {
        if (!mounted || _lastStart != null) return;
        final loaded = context.read<CycleController>().cycles;
        if (loaded.isNotEmpty) setState(() => _lastStart = loaded.last.startDate);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int step) {
    setState(() => _step = step);
    _pages.animateToPage(step,
        duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  Future<void> _finish() async {
    final session = context.read<SessionController>();
    final cycle = context.read<CycleController>();
    final navigator = Navigator.of(context);
    final user = session.user;
    setState(() => _saving = true);

    if (user != null) {
      await session.updateProfile(user.copyWith(
        ageGroup: _ageGroup,
        averagePeriodDuration: _periodLength,
        averageCycleLength: _cycleUnknown ? 28 : _cycleLength,
        regularity: _regularity,
        cycleSetupCompleted: true,
      ));
    }
    final start = _lastStart;
    if (start != null && !_lastStartUnknown) {
      await cycle.addPeriodDays(start, _periodLength);
    } else {
      await cycle.load();
    }

    if (!mounted) return;
    if (widget.isEditing && navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _ageGroup != AgeGroup.unknown;
      case 4:
        return _lastStart != null || _lastStartUnknown;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _step == _steps - 1;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.isEditing,
        title: Text(AppLanguage.tr('Conozcamos tu ciclo', 'Let’s get to know your cycle')),
      ),
      body: SoftBackground(
        child: SafeArea(
          child: CenteredContent(
            maxWidth: 560,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                children: [
                  _Progress(step: _step, total: _steps),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ageStep(),
                        _periodStep(),
                        _cycleStep(),
                        _regularityStep(),
                        _lastPeriodStep(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => _go(_step - 1),
                            child: Text(AppLanguage.tr('Atrás', 'Back')),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: !_canContinue || _saving
                              ? null
                              : () => last ? _finish() : _go(_step + 1),
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Icon(last ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded),
                          label: Text(last
                              ? AppLanguage.tr('Ver mi predicción', 'See my prediction')
                              : AppLanguage.tr('Continuar', 'Continue')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Paso 1: edad ─────────────────────────────────────────────────────────
  Widget _ageStep() => _StepScaffold(
        icon: const MoonWidget(size: 64, progress: 0.2),
        title: AppLanguage.tr('¿En qué etapa estás?', 'Which stage are you in?'),
        subtitle: AppLanguage.tr(
          'En la adolescencia los ciclos suelen variar más, así que ajustamos la predicción.',
          'Cycles vary more during adolescence, so we adjust the prediction.',
        ),
        children: [
          _OptionTile(
            icon: Icons.face_retouching_natural,
            title: AppLanguage.tr('Adolescente', 'Teen'),
            subtitle: AppLanguage.tr('Menos de 18 años · ciclos de 21 a 45 días son normales',
                'Under 18 · cycles of 21 to 45 days are normal'),
            selected: _ageGroup == AgeGroup.teen,
            onTap: () => setState(() => _ageGroup = AgeGroup.teen),
          ),
          _OptionTile(
            icon: Icons.person_rounded,
            title: AppLanguage.tr('Adulta', 'Adult'),
            subtitle: AppLanguage.tr('18 años o más · lo habitual son ciclos de 24 a 38 días',
                '18 or older · cycles of 24 to 38 days are typical'),
            selected: _ageGroup == AgeGroup.adult,
            onTap: () => setState(() => _ageGroup = AgeGroup.adult),
          ),
        ],
      );

  // ── Paso 2: duración del periodo ─────────────────────────────────────────
  Widget _periodStep() => _StepScaffold(
        icon: const Icon(Icons.water_drop_rounded, size: 56, color: AppColors.deepPink),
        title: AppLanguage.tr('¿Cuántos días dura tu periodo?', 'How many days does your period last?'),
        subtitle: AppLanguage.tr(
          'Cuenta desde el primer día de sangrado hasta el último. Lo más común es entre 3 y 7 días.',
          'Count from the first to the last day of bleeding. Most commonly 3 to 7 days.',
        ),
        children: [
          _NumberPicker(
            value: _periodLength,
            min: 1,
            max: 10,
            unit: AppLanguage.tr('días', 'days'),
            onChanged: (v) => setState(() => _periodLength = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in [3, 4, 5, 6, 7, 8])
                ChoiceChip(
                  label: Text('$d'),
                  selected: _periodLength == d,
                  selectedColor: AppColors.softPink,
                  onSelected: (_) => setState(() => _periodLength = d),
                ),
              ActionChip(
                label: Text(AppLanguage.tr('No estoy segura (5)', 'Not sure (5)')),
                onPressed: () => setState(() => _periodLength = 5),
              ),
            ],
          ),
          if (_periodLength > 7)
            _Note(AppLanguage.tr(
              'Un sangrado de más de 7–8 días es poco común. Si te pasa seguido, coméntalo con un profesional de salud.',
              'Bleeding for more than 7–8 days is uncommon. If it happens often, talk to a health professional.',
            )),
          if (_periodLength < 2)
            _Note(AppLanguage.tr(
              'Un periodo de 1 día es poco común; si es tu caso, está bien registrarlo así.',
              'A 1-day period is uncommon; if that is your case, it is fine to log it.',
            )),
        ],
      );

  // ── Paso 3: duración del ciclo ───────────────────────────────────────────
  Widget _cycleStep() {
    final teen = _ageGroup == AgeGroup.teen;
    final min = teen ? 21 : 24;
    final max = teen ? 45 : 38;
    final outOfRange = !_cycleUnknown && (_cycleLength < min || _cycleLength > max);
    return _StepScaffold(
      icon: const Icon(Icons.loop_rounded, size: 56, color: AppColors.purple),
      title: AppLanguage.tr('¿Cada cuántos días te llega?', 'How often does it come?'),
      subtitle: AppLanguage.tr(
        'Días desde el inicio de un periodo hasta el inicio del siguiente. '
            '${teen ? 'En la adolescencia, entre 21 y 45 días es normal.' : 'Lo habitual en adultas es entre 24 y 38 días (unos 28 en promedio).'}',
        'Days from the start of one period to the start of the next. '
            '${teen ? 'For teens, 21 to 45 days is normal.' : 'For adults, 24 to 38 days is typical (about 28 on average).'}',
      ),
      children: [
        AnimatedOpacity(
          opacity: _cycleUnknown ? 0.35 : 1,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: _cycleUnknown,
            child: Column(
              children: [
                _BigValue(value: _cycleLength, unit: AppLanguage.tr('días', 'days')),
                Slider(
                  value: _cycleLength.toDouble(),
                  min: 20,
                  max: 45,
                  divisions: 25,
                  label: '$_cycleLength',
                  onChanged: (v) => setState(() => _cycleLength = v.round()),
                ),
              ],
            ),
          ),
        ),
        CheckboxListTile(
          value: _cycleUnknown,
          onChanged: (v) => setState(() => _cycleUnknown = v ?? false),
          title: Text(AppLanguage.tr('No lo sé (usar 28 días)', 'I don’t know (use 28 days)')),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (outOfRange)
          _Note(AppLanguage.tr(
            'Está fuera del rango habitual ($min–$max días). La app lo tendrá en cuenta; si se repite, puedes comentarlo con un profesional.',
            'This is outside the usual range ($min–$max days). The app will take it into account; if it keeps happening, you can talk to a professional.',
          )),
      ],
    );
  }

  // ── Paso 4: regularidad ──────────────────────────────────────────────────
  Widget _regularityStep() => _StepScaffold(
        icon: const Icon(Icons.timeline_rounded, size: 56, color: AppColors.purple),
        title: AppLanguage.tr('¿Tu ciclo es regular?', 'Is your cycle regular?'),
        subtitle: AppLanguage.tr(
          'Si varía mucho, la predicción mostrará más días posibles de inicio.',
          'If it varies a lot, the prediction will show more possible start days.',
        ),
        children: [
          _OptionTile(
            icon: Icons.check_circle_outline_rounded,
            title: AppLanguage.tr('Sí, bastante regular', 'Yes, fairly regular'),
            subtitle: AppLanguage.tr('Me llega más o menos en la misma fecha (±1–3 días)',
                'It comes around the same date (±1–3 days)'),
            selected: _regularity == CycleRegularity.regular,
            onTap: () => setState(() => _regularity = CycleRegularity.regular),
          ),
          _OptionTile(
            icon: Icons.shuffle_rounded,
            title: AppLanguage.tr('No, es irregular', 'No, it’s irregular'),
            subtitle: AppLanguage.tr('A veces se adelanta o se atrasa varios días',
                'Sometimes it comes several days early or late'),
            selected: _regularity == CycleRegularity.irregular,
            onTap: () => setState(() => _regularity = CycleRegularity.irregular),
          ),
          _OptionTile(
            icon: Icons.help_outline_rounded,
            title: AppLanguage.tr('No estoy segura', 'I’m not sure'),
            subtitle: AppLanguage.tr('Lo iremos aprendiendo con tus registros',
                'We’ll learn it from your logs'),
            selected: _regularity == CycleRegularity.unsure,
            onTap: () => setState(() => _regularity = CycleRegularity.unsure),
          ),
        ],
      );

  // ── Paso 5: última menstruación ──────────────────────────────────────────
  Widget _lastPeriodStep() {
    final today = AppDateUtils.today();
    return _StepScaffold(
      icon: const Icon(Icons.event_rounded, size: 56, color: AppColors.deepPink),
      title: AppLanguage.tr('¿Cuándo empezó tu última menstruación?',
          'When did your last period start?'),
      subtitle: AppLanguage.tr('Elige el primer día de sangrado.', 'Pick the first day of bleeding.'),
      children: [
        AnimatedOpacity(
          opacity: _lastStartUnknown ? 0.35 : 1,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: _lastStartUnknown,
            child: SpringCard(
              padding: const EdgeInsets.all(4),
              child: CalendarDatePicker(
                initialDate: _lastStart ?? today,
                firstDate: AppDateUtils.addDays(today, -120),
                lastDate: today,
                onDateChanged: (d) => setState(() => _lastStart = AppDateUtils.dateOnly(d)),
              ),
            ),
          ),
        ),
