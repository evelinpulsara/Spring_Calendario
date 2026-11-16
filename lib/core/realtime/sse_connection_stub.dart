import 'package:spring_calendario/core/realtime/sse_connection.dart';

SseConnection createSseConnection() => _NoSseConnection();

/// Fuera del navegador no hay `EventSource`: el tiempo real queda apagado.
class _NoSseConnection implements SseConnection {
  @override
  bool get isSupported => false;

  @override
  void open(
    String url, {
    required List<String> eventNames,
    required void Function(String event, String data) onEvent,
    required void Function() onError,
  }) {}

  @override
  void close() {}
}
