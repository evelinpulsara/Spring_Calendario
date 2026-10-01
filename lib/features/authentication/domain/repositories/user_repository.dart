import 'package:lunaflow/features/authentication/domain/entities/user.dart';

/// Thrown when login or registration fails.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Contract for user data. Implement it with Supabase, Firebase or a REST API.
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
