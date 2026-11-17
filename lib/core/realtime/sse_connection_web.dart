import 'dart:js_interop';

import 'package:spring_calendario/core/realtime/sse_connection.dart';
import 'package:web/web.dart' as web;

SseConnection createSseConnection() => _WebSseConnection();

class _WebSseConnection implements SseConnection {
  web.EventSource? _source;

  @override
  bool get isSupported => true;

  @override
  void open(
    String url, {
    required List<String> eventNames,
    required void Function(String event, String data) onEvent,
    required void Function() onError,
  }) {
    close();
    final source = web.EventSource(url);
    _source = source;
    for (final name in eventNames) {
      source.addEventListener(
        name,
        ((web.MessageEvent e) => onEvent(name, e.data.dartify()?.toString() ?? '')).toJS,
      );
    }
    source.onerror = ((web.Event _) => onError()).toJS;
  }

  @override
  void close() {
    _source?.close();
    _source = null;
  }
}
