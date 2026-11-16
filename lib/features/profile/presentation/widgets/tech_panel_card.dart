import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/web/browser_features.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/shared/widgets/section_title.dart';
import 'package:spring_calendario/shared/widgets/spring_card.dart';

/// Panel técnico (temas del curso): tiempo real con SSE, métricas INP/FCP,
/// Service Worker y exportación con Web Worker. Solo aparece en la web.
class TechPanelCard extends StatefulWidget {
  const TechPanelCard({super.key});

  @override
  State<TechPanelCard> createState() => _TechPanelCardState();
}

class _TechPanelCardState extends State<TechPanelCard> {
  WebVitals? _vitals;
  Timer? _refresh;
  bool _exporting = false;
  ExportResult? _lastExport;

  @override
  void initState() {
    super.initState();
    _vitals = BrowserFeatures.readVitals();
    // Las métricas cambian con cada interacción: se leen cada 2 s.
    _refresh = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => _vitals = BrowserFeatures.readVitals());
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  Future<void> _export() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final payload = {
      'language': t.isSpanish ? 'es' : 'en',
      'periodDays': [
        for (final e in context.read<CycleController>().periodEntries)
          {'date': ApiClient.date(e.date), 'flow': e.flow.name},
      ],
      'symptoms': [
        for (final e in context.read<SymptomController>().entries)
          {'date': ApiClient.date(e.date), 'type': e.type.name, 'intensity': e.intensity},
      ],
      'intimacy': [
        for (final e in context.read<IntimacyController>().entries)
          {'date': ApiClient.date(e.date), 'protection': e.protection.name},
      ],
    };

    setState(() => _exporting = true);
    // Event Loop: esperar a que se pinte el frame con "Exportando..." antes de
    // seguir. Así la respuesta visual al clic es inmediata (mejor INP).
    await WidgetsBinding.instance.endOfFrame;

    try {
      final result = await BrowserFeatures.exportCsv(payload, 'spring-registros.csv');
      if (!mounted) return;
      setState(() => _lastExport = result);
      messenger.showSnackBar(SnackBar(
        content: Text(t.isSpanish
            ? '${result.rows} registros exportados (Web Worker: ${result.workerMs.toStringAsFixed(1)} ms)'
            : '${result.rows} records exported (Web Worker: ${result.workerMs.toStringAsFixed(1)} ms)'),
      ));
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(t.isSpanish ? 'No se pudo exportar.' : 'Could not export.'),
      ));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final es = t.isSpanish;
    final realtime = context.watch<RealtimeService>();
    final v = _vitals;
    final muted = TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.35);

    return SpringCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(es ? 'Rendimiento y tiempo real' : 'Performance & real time'),

          // ── Tiempo real (SSE) ────────────────────────────────────────────
          _Row(
            icon: Icons.sync_rounded,
            label: es ? 'Sincronización en vivo (SSE)' : 'Live sync (SSE)',
            value: _realtimeLabel(realtime.status, es),
            color: _realtimeColor(realtime.status),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 10),
            child: Text(
              es
                  ? 'Cambios recibidos de otros dispositivos: ${realtime.eventsReceived}'
                  : 'Changes received from other devices: ${realtime.eventsReceived}',
              style: muted,
            ),
          ),

          // ── INP ──────────────────────────────────────────────────────────
          if (v == null || !v.supported)
            _Row(
              icon: Icons.touch_app_rounded,
              label: 'INP',
              value: es ? 'No disponible' : 'Not available',
              color: AppColors.textMuted,
            )
          else
            _Row(
              icon: Icons.touch_app_rounded,
              label: 'INP',
              value: v.inp == null ? (es ? 'Toca algo…' : 'Tap something…') : '${v.inp} ms · ${_ratingLabel(v.rating, es)}',
              color: _ratingColor(v.rating),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 10),
            child: Text(
              v == null || !v.supported
                  ? (es
                      ? 'Este navegador no mide INP (Safari aún no tiene Event Timing API). Ábrela en Chrome o Edge.'
                      : 'This browser cannot measure INP (no Event Timing API in Safari yet). Use Chrome or Edge.')
                  : v.inp == null
                      ? (es ? 'Se mide con cada clic o toque.' : 'Measured on every click or tap.')
                      : (es
                          ? 'Entrada ${v.inputDelay} ms + Procesamiento ${v.processing} ms + Presentación ${v.presentation} ms'
                              ' · ${v.interactions} interacciones · ${v.longTasks} tareas largas'
                          : 'Input ${v.inputDelay} ms + Processing ${v.processing} ms + Presentation ${v.presentation} ms'
                              ' · ${v.interactions} interactions · ${v.longTasks} long tasks'),
              style: muted,
            ),
          ),

          // ── FCP / Service Worker ─────────────────────────────────────────
          _Row(
            icon: Icons.bolt_rounded,
            label: es ? 'Primer contenido pintado (FCP)' : 'First Contentful Paint',
            value: v?.fcp == null ? '—' : '${v!.fcp} ms',
            color: AppColors.purple,
          ),
          _Row(
            icon: Icons.wifi_off_rounded,
            label: es ? 'Modo sin conexión (Service Worker)' : 'Offline mode (Service Worker)',
            value: v?.serviceWorker == true ? (es ? 'Activo' : 'Active') : (es ? 'Inactivo' : 'Inactive'),
            color: v?.serviceWorker == true ? AppColors.normalDay : AppColors.textMuted,
          ),
          const SizedBox(height: 12),

          // ── Web Worker ───────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded),
            label: Text(_exporting
                ? (es ? 'Exportando…' : 'Exporting…')
                : (es ? 'Exportar mis datos (CSV)' : 'Export my data (CSV)')),
          ),
          const SizedBox(height: 6),
          Text(
            _lastExport == null
                ? (es
                    ? 'El archivo se arma en un Web Worker (otro hilo), sin congelar la app.'
                    : 'The file is built in a Web Worker (another thread) without freezing the app.')
                : (es
                    ? 'Último: ${_lastExport!.rows} registros en ${_lastExport!.workerMs.toStringAsFixed(1)} ms dentro del worker.'
                    : 'Last: ${_lastExport!.rows} records in ${_lastExport!.workerMs.toStringAsFixed(1)} ms inside the worker.'),
            style: muted,
          ),
        ],
      ),
    );
  }

  static String _realtimeLabel(RealtimeStatus s, bool es) => switch (s) {
        RealtimeStatus.live => es ? 'En vivo' : 'Live',
        RealtimeStatus.connecting => es ? 'Conectando…' : 'Connecting…',
        RealtimeStatus.retrying => es ? 'Reintentando…' : 'Retrying…',
        RealtimeStatus.off => es ? 'Apagada' : 'Off',
      };

  static Color _realtimeColor(RealtimeStatus s) => switch (s) {
        RealtimeStatus.live => AppColors.normalDay,
        RealtimeStatus.connecting || RealtimeStatus.retrying => const Color(0xFFE0A030),
        RealtimeStatus.off => AppColors.textMuted,
      };

  static String _ratingLabel(String? r, bool es) => switch (r) {
        'good' => es ? 'Bueno' : 'Good',
        'needs-improvement' => es ? 'Necesita mejora' : 'Needs improvement',
        'poor' => es ? 'Pobre' : 'Poor',
        _ => '',
      };

  static Color _ratingColor(String? r) => switch (r) {
        'good' => AppColors.normalDay,
        'needs-improvement' => const Color(0xFFE0A030),
        'poor' => AppColors.deepPink,
        _ => AppColors.purple,
      };
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
