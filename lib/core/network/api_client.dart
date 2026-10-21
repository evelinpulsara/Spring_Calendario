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

