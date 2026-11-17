import 'package:spring_calendario/features/authentication/domain/entities/user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });
  Future<User> updateUser(User user);
  Future<void> logout();
}
