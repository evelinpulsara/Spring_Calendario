import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/core/realtime/sse_connection.dart';

/// Qué cambió en el servidor (evento `records-changed`).
enum RealtimeResource { periodDays, symptoms, intimacy, all }

class RealtimeEvent {
  const RealtimeEvent(this.resource, this.at);

  final RealtimeResource resource;
  final DateTime at;

  static const _names = {
    'period-days': RealtimeResource.periodDays,
    'symptoms': RealtimeResource.symptoms,
    'intimacy': RealtimeResource.intimacy,
    'all': RealtimeResource.all,
  };

  /// Parsea el JSON del evento según el contrato (RealtimeEvent en openapi.yaml).
  /// Si no lo cumple, lanza [ContractViolation].
  static RealtimeEvent parse(String data) {
    final Object? json;
    try {
      json = jsonDecode(data);
    } on FormatException {
      throw ContractViolation('evento', 'no es JSON');
    }
    final j = JsonObject.parse(json, 'evento');
    final resource = _names[j.string('resource')];
    if (resource == null) throw ContractViolation('evento.resource', 'valor desconocido');
    final at = DateTime.tryParse(j.string('at'));
    if (at == null) throw ContractViolation('evento.at', 'fecha inválida');
    return RealtimeEvent(resource, at);
  }
}

enum RealtimeStatus { off, connecting, live, retrying }

/// Tiempo real (tema 5 del curso): mantiene abierta una conexión SSE con el
/// backend. Cuando la usuaria cambia un registro en otro dispositivo o pestaña,
/// llega `records-changed` y la app recarga solo esos datos, sin *polling*.
class RealtimeService extends ChangeNotifier {
  RealtimeService(this._api, {SseConnection? connection})
      : _connection = connection ?? SseConnection();

  final ApiClient _api;
  final SseConnection _connection;
  final _changes = StreamController<RealtimeEvent>.broadcast();

  RealtimeStatus _status = RealtimeStatus.off;
  int _eventsReceived = 0;
  DateTime? _lastEventAt;
  bool _wanted = false;
  int _attempt = 0;
  Timer? _retry;

  bool get isSupported => _connection.isSupported;
  RealtimeStatus get status => _status;
  int get eventsReceived => _eventsReceived;
  DateTime? get lastEventAt => _lastEventAt;

  /// Cambios que llegan del servidor.
  Stream<RealtimeEvent> get changes => _changes.stream;

  /// Abre la conexión (si ya está abierta no hace nada).
  void start() {
    if (!isSupported || _wanted) return;
    _wanted = true;
    _attempt = 0;
    unawaited(_connect());
  }

  void stop() {
    _wanted = false;
    _retry?.cancel();
    _connection.close();
    _setStatus(RealtimeStatus.off);
  }

  Future<void> _connect() async {
    if (!_wanted) return;
    _setStatus(RealtimeStatus.connecting);
    try {
      // 1) Ticket de un solo uso (EventSource no puede mandar el token).
      final ticket = JsonObject.parse(await _api.post('/api/events/ticket', null), 'ticket')
          .string('ticket');
      if (!_wanted) return;
      // 2) Stream SSE.
      _connection.open(
        '${_api.baseUrl}/api/events/stream?ticket=${Uri.encodeQueryComponent(ticket)}',
        eventNames: const ['connected', 'records-changed'],
        onEvent: _onEvent,
        onError: _onError,
      );
    } on ApiError catch (e) {
      if (e.status == 401) return stop(); // sesión vencida: no insistir
      _scheduleRetry();
    } catch (_) {
      _scheduleRetry();
    }
  }

  void _onEvent(String name, String data) {
    if (name == 'connected') {
      _attempt = 0;
      _setStatus(RealtimeStatus.live);
      return;
    }
    final RealtimeEvent event;
    try {
      event = RealtimeEvent.parse(data);
    } on ContractViolation catch (e) {
      debugPrint('Evento ignorado: $e');
      return;
    }
    _eventsReceived++;
    _lastEventAt = DateTime.now();
    notifyListeners();
    _changes.add(event);
  }

  /// El ticket es de un solo uso, así que la reconexión automática del
  /// navegador fallaría: cerramos y pedimos un ticket nuevo con espera
  /// creciente (5 s, 10 s, 20 s... máximo 60 s).
  void _onError() {
    _connection.close();
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_wanted) return;
    _setStatus(RealtimeStatus.retrying);
    final seconds = min(60, 5 * pow(2, _attempt).toInt());
    _attempt++;
    _retry?.cancel();
    _retry = Timer(Duration(seconds: seconds), () => unawaited(_connect()));
  }

  void _setStatus(RealtimeStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    _changes.close();
    super.dispose();
  }
}
