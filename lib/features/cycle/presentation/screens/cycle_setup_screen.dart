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
