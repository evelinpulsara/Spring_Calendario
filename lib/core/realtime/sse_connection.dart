import 'package:spring_calendario/core/realtime/sse_connection_stub.dart'
    if (dart.library.js_interop) 'package:spring_calendario/core/realtime/sse_connection_web.dart'
    as impl;

abstract class SseConnection {
  factory SseConnection() => impl.createSseConnection();

  bool get isSupported;

  void open(
    String url, {
    required List<String> eventNames,
    required void Function(String event, String data) onEvent,
    required void Function() onError,
  });

  void close();
}
