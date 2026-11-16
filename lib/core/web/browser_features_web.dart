import 'dart:async';
import 'dart:js_interop';

import 'package:spring_calendario/core/web/browser_features.dart';
import 'package:web/web.dart' as web;

const bool isWeb = true;

@JS('springVitals')
external JSObject? get _springVitals;

WebVitals? readVitals() {
  final raw = _springVitals?.dartify();
  if (raw is! Map) return null;
  int? n(String k) => (raw[k] as num?)?.round();
  return WebVitals(
    supported: raw['supported'] == true,
    inp: n('inp'),
    rating: raw['rating'] as String?,
    inputDelay: n('inputDelay'),
    processing: n('processing'),
    presentation: n('presentation'),
    interactions: n('interactions') ?? 0,
    longTasks: n('longTasks') ?? 0,
    fcp: n('fcp'),
    ttfb: n('ttfb'),
    serviceWorker: raw['serviceWorker'] == true,
    crossOriginIsolated: raw['crossOriginIsolated'] == true,
  );
}

/// Envía los datos al Web Worker con postMessage, espera su respuesta y
/// descarga el CSV. El Main Thread no hace el trabajo pesado.
Future<ExportResult> exportCsv(Map<String, Object?> payload, String fileName) {
  final completer = Completer<ExportResult>();
  final worker = web.Worker('workers/export_worker.js'.toJS);

  worker.onmessage = ((web.MessageEvent e) {
    worker.terminate();
    final data = e.data.dartify();
    if (data is! Map) {
      completer.completeError(StateError('Respuesta inválida del worker'));
      return;
    }
    _download(data['csv'] as String, fileName);
    final summary = data['summary'];
    completer.complete(ExportResult(
      rows: (data['rows'] as num).toInt(),
      workerMs: (data['workerMs'] as num).toDouble(),
      topSymptom: summary is List && summary.isNotEmpty ? (summary.first as Map)['type'] as String? : null,
    ));
  }).toJS;
  worker.onerror = ((web.Event _) {
    worker.terminate();
    if (!completer.isCompleted) completer.completeError(StateError('El worker falló'));
  }).toJS;

  worker.postMessage(payload.jsify());
  return completer.future;
}

void _download(String csv, String fileName) {
  // "﻿" para que Excel reconozca las tildes (UTF-8).
  final blob = web.Blob(['﻿$csv'.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body?.append(a);
  a.click();
  a.remove();
  web.URL.revokeObjectURL(url);
}
