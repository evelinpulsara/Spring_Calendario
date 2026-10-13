import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_guidance.dart';
import 'package:spring_calendario/features/intimacy/domain/services/pregnancy_risk.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/widgets/intimacy_visuals.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';

/// Abre el panel para registrar una relación sexual en [date].
/// En celular es un panel inferior; en computadora, una ventana centrada.
Future<void> showIntimacySheet(BuildContext context, DateTime date) {
  final day = AppDateUtils.dateOnly(date);
  if (Breakpoints.isWide(context)) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24),
            child: _IntimacySheet(date: day),
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IntimacySheet(date: AppDateUtils.dateOnly(date)),
  );
}

class _IntimacySheet extends StatefulWidget {
  const _IntimacySheet({required this.date});

  final DateTime date;

  @override
  State<_IntimacySheet> createState() => _IntimacySheetState();
}

class _IntimacySheetState extends State<_IntimacySheet> {
  late ProtectionType? _selected =
      context.read<IntimacyController>().entryFor(widget.date)?.protection;

  Future<void> _save() async {
    final protection = _selected;
    if (protection == null) return;
    final intimacy = context.read<IntimacyController>();
    final projection = context.read<CycleController>().projection;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await intimacy.save(widget.date, protection);
    navigator.pop();

    final risk = intimacy.riskFor(widget.date, projection);
    messenger.showSnackBar(SnackBar(
      content: Text(risk != null && risk.risk == PregnancyRisk.high
          ? AppLanguage.tr(
              'Guardado. Revisa el aviso en Inicio.', 'Saved. Check the notice on Home.')
          : AppLanguage.tr('Registro guardado', 'Entry saved')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final existing = context.watch<IntimacyController>().entryFor(widget.date);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GentlePulse(
                  child: Icon(Icons.favorite_rounded, color: AppColors.deepPink, size: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLanguage.tr('Relación sexual', 'Sexual activity'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(AppDateUtils.longDate(widget.date),
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 18),
            Text(
              AppLanguage.tr('¿Usaron protección?', 'Did you use protection?'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...staggered(
              [
                for (final type in ProtectionType.values)
                  _ProtectionOption(
                    type: type,
                    selected: _selected == type,
                    onTap: () => setState(() => _selected = type),
                  ),
              ],
              step: const Duration(milliseconds: 50),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${AppLanguage.tr('Es privado: se guarda en tu dispositivo.', 'Private: saved on your device.')} '
                    '${PregnancyGuidance.disclaimer}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selected == null ? null : _save,
                icon: const Icon(Icons.check_rounded),
