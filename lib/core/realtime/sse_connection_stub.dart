import 'package:spring_calendario/core/realtime/sse_connection.dart';

SseConnection createSseConnection() => _NoSseConnection();

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
