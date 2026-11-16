import 'package:spring_calendario/core/realtime/sse_connection_stub.dart'
    if (dart.library.js_interop) 'package:spring_calendario/core/realtime/sse_connection_web.dart'
    as impl;

/// Conexión Server-Sent Events. En la web usa `EventSource` del navegador;
/// en otras plataformas (y en los tests) no hace nada.
abstract class SseConnection {
  /// Crea la implementación de la plataforma actual.
  factory SseConnection() => impl.createSseConnection();

  bool get isSupported;

  /// Abre el stream y escucha los eventos [eventNames].
  void open(
    String url, {
    required List<String> eventNames,
    required void Function(String event, String data) onEvent,
    required void Function() onError,
  });

  void close();
}
