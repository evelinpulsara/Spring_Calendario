import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spring_calendario/core/config/api_config.dart';

/// Error de la API con un código (por ejemplo "email_taken") o de conexión.
class ApiError implements Exception {
  const ApiError(this.status, this.code);

  /// 0 = no hubo conexión con el servidor.
  final int status;
  final String code;

  bool get isConnection => status == 0;

  @override
  String toString() => 'ApiError($status, $code)';
}

/// Cliente HTTP del backend: agrega el token de sesión y convierte errores.
class ApiClient {
  ApiClient({http.Client? client, String baseUrl = ApiConfig.baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  static const _tokenKey = 'spring_session_token';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;
  final String _baseUrl;
  String? _token;

  http.Client get httpClient => _client;
  String get baseUrl => _baseUrl;

  /// Headers con el token, para otras llamadas (por ejemplo la IA).
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  bool get hasToken => _token != null;

  /// Recupera la sesión guardada (sobrevive a recargar la página).
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, Object? body) => _send('POST', path, body);
  Future<dynamic> put(String path, Object? body) => _send('PUT', path, body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll(authHeaders);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request).timeout(_timeout));
    } on TimeoutException {
      throw const ApiError(0, 'timeout');
    } catch (_) {
      throw const ApiError(0, 'connection');
    }

    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    var code = 'error';
    try {
      code = (jsonDecode(text) as Map<String, dynamic>)['error'] as String? ?? code;
    } catch (_) {}
    if (response.statusCode == 401 && code == 'error') code = 'session_expired';
    throw ApiError(response.statusCode, code);
  }

  /// Fecha en formato YYYY-MM-DD.
  static String date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
