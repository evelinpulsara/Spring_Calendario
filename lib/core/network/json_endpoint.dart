import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:spring_calendario/core/config/api_config.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';

typedef HeadersProvider = Map<String, String> Function();

class JsonEndpoint {
  JsonEndpoint(
    String path, {
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.aiTimeout,
    HeadersProvider? headers,
  })  : _uri = Uri.parse('$baseUrl$path'),
        _client = client ?? http.Client(),
        _timeout = timeout,
        _headers = headers ?? _jsonOnly;

  final Uri _uri;
  final http.Client _client;
  final Duration _timeout;
  final HeadersProvider _headers;

  static Map<String, String> _jsonOnly() => const {'Content-Type': 'application/json'};

  Future<JsonObject> post(Map<String, Object?> body) async {
    final response = await _client
        .post(_uri, headers: _headers(), body: jsonEncode(body))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiError(response.statusCode, response.body);
    }
    return JsonObject.parse(jsonDecode(utf8.decode(response.bodyBytes)), _uri.path);
  }
}

mixin FallbackOnError {
  String get fallbackReason;

  Future<T> remoteOr<T>(Future<T> Function() remote, Future<T> Function() fallback) async {
    try {
      return await remote();
    } catch (error) {
      debugPrint('$fallbackReason ($error)');
      return fallback();
    }
  }
}
