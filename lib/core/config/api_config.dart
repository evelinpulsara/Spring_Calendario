/// Dirección del backend (Spring_Backend).
///
/// Por defecto usa el backend local. Para otra dirección:
///   flutter run -d chrome --dart-define=API_URL=https://mi-backend.com
///   flutter build web --dart-define=API_URL=https://mi-backend.com
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// true = usar el backend y la base de datos. Para probar sin servidor:
  ///   flutter run -d chrome --dart-define=USE_BACKEND=false
  static const bool useBackend = bool.fromEnvironment('USE_BACKEND', defaultValue: true);

  /// Tiempo máximo de espera para la respuesta de la IA.
  static const Duration aiTimeout = Duration(seconds: 70);
}
