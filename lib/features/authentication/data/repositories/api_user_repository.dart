import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/authentication/domain/repositories/user_repository.dart';

/// Cuentas guardadas en la base de datos a través del backend.
class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._api);

  final ApiClient _api;
  User? _current;

  @override
  Future<User?> getCurrentUser() async {
    await _api.loadToken();
    if (!_api.hasToken) return null;
    try {
      _current = userFromJson(await _api.get('/api/me') as Map<String, dynamic>);
      return _current;
    } on ApiError catch (e) {
      if (e.status == 401) await _api.clearToken(); // sesión vencida
      return null;
    }
  }

  @override
  Future<User> login({required String email, required String password}) =>
      _auth('/api/auth/login', {'email': email.trim(), 'password': password});

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _auth('/api/auth/register',
          {'name': name.trim(), 'email': email.trim(), 'password': password});

  Future<User> _auth(String path, Map<String, String> body) async {
    try {
      final json = await _api.post(path, body) as Map<String, dynamic>;
      await _api.saveToken(json['token'] as String);
      return _current = userFromJson(json['user'] as Map<String, dynamic>);
    } on ApiError catch (e) {
      throw AuthException(messageFor(e));
    }
  }

  @override
  Future<User> updateUser(User user) async {
    final json = await _api.put('/api/me', userToJson(user)) as Map<String, dynamic>;
    return _current = userFromJson(json);
  }

  @override
  Future<void> logout() async {
    _current = null;
    await _api.clearToken();
  }

  /// Mensaje para la usuaria según el código de error del backend.
  static String messageFor(ApiError e) {
    switch (e.code) {
      case 'invalid_credentials':
        return AppLanguage.tr('Correo o contraseña incorrectos.', 'Incorrect email or password.');
      case 'email_taken':
        return AppLanguage.tr(
            'Ya existe una cuenta con este correo.', 'An account with this email already exists.');
      case 'connection':
      case 'timeout':
        return AppLanguage.tr('No se pudo conectar con el servidor. Revisa tu conexión.',
            'Could not reach the server. Check your connection.');
      default:
        return AppLanguage.tr('Datos no válidos. Revisa e intenta de nuevo.',
            'Invalid data. Please check and try again.');
    }
  }
