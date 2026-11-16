import 'package:spring_calendario/core/web/browser_features_stub.dart'
    if (dart.library.js_interop) 'package:spring_calendario/core/web/browser_features_web.dart'
    as impl;

/// Métricas que mide `web/perf/web_vitals.js` en el navegador (tema 1).
class WebVitals {
  const WebVitals({
    required this.supported,
    this.inp,
    this.rating,
    this.inputDelay,
    this.processing,
    this.presentation,
    this.interactions = 0,
    this.longTasks = 0,
    this.fcp,
    this.ttfb,
    this.serviceWorker = false,
    this.crossOriginIsolated = false,
  });

  /// true si el navegador tiene la Event Timing API (Safari todavía no).
  final bool supported;

  /// INP = [inputDelay] + [processing] + [presentation] (ms).
  final int? inp;

  /// good (≤ 200 ms) | needs-improvement (≤ 500 ms) | poor (> 500 ms).
  final String? rating;
  final int? inputDelay;
  final int? processing;
  final int? presentation;
  final int interactions;

  /// Tareas de más de 50 ms que bloquearon el Main Thread.
  final int longTasks;
  final int? fcp;
  final int? ttfb;
  final bool serviceWorker;

  /// Requisito para usar SharedArrayBuffer (headers COOP/COEP).
  final bool crossOriginIsolated;
}

/// Resultado de exportar los registros en el Web Worker.
class ExportResult {
  const ExportResult({required this.rows, required this.workerMs, required this.topSymptom});

  final int rows;

  /// Lo que tardó el worker en su propio hilo.
  final double workerMs;
  final String? topSymptom;
}

/// Funciones del navegador. Fuera de la web devuelven null / no hacen nada.
abstract final class BrowserFeatures {
  static bool get isWeb => impl.isWeb;

  static WebVitals? readVitals() => impl.readVitals();

  /// Arma el CSV en un Web Worker (otro hilo) y lo descarga.
  static Future<ExportResult> exportCsv(Map<String, Object?> payload, String fileName) =>
      impl.exportCsv(payload, fileName);
}
