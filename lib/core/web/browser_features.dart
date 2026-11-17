import 'package:spring_calendario/core/web/browser_features_stub.dart'
    if (dart.library.js_interop) 'package:spring_calendario/core/web/browser_features_web.dart'
    as impl;

class WebVitals {
  const WebVitals({
    required this.supported,
    this.estimated = false,
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

  final bool supported;

  final bool estimated;

  final int? inp;

  final String? rating;
  final int? inputDelay;
  final int? processing;
  final int? presentation;
  final int interactions;

  final int longTasks;
  final int? fcp;
  final int? ttfb;
  final bool serviceWorker;

  final bool crossOriginIsolated;
}

class ExportResult {
  const ExportResult({required this.rows, required this.workerMs, required this.topSymptom});

  final int rows;

  final double workerMs;
  final String? topSymptom;
}

abstract final class BrowserFeatures {
  static bool get isWeb => impl.isWeb;

  static WebVitals? readVitals() => impl.readVitals();

  static void onVisibilityChange(void Function(bool hidden) listener) =>
      impl.onVisibilityChange(listener);

  static Future<ExportResult> exportCsv(Map<String, Object?> payload, String fileName) =>
      impl.exportCsv(payload, fileName);
}
