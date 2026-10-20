/// Dirección del backend (Spring_Backend).
///
/// Por defecto usa el backend local. Para otra dirección:
///   flutter run -d chrome --dart-define=API_URL=https://mi-backend.com
///   flutter build web --dart-define=API_URL=https://mi-backend.com
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
