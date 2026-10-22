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

