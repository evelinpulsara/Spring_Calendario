import 'package:spring_calendario/core/web/browser_features.dart';

const bool isWeb = false;

WebVitals? readVitals() => null;

void onVisibilityChange(void Function(bool hidden) listener) {}

Future<ExportResult> exportCsv(Map<String, Object?> payload, String fileName) =>
    Future.error(UnsupportedError('La exportación con Web Worker solo existe en la web.'));
