class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const bool useBackend = bool.fromEnvironment('USE_BACKEND', defaultValue: true);

  static const Duration aiTimeout = Duration(seconds: 70);
}
