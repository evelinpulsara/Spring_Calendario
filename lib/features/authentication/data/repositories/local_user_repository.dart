import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/features/authentication/domain/entities/user.dart';
import 'package:lunaflow/features/authentication/domain/repositories/user_repository.dart';

/// In-memory authentication used by the MVP.
///
/// WARNING: this only simulates authentication. A real implementation must
/// delegate to a backend and never keep credentials on the device.
class LocalUserRepository implements UserRepository {
  LocalUserRepository() {
    if (AppConstants.seedDemoData) {
      const demo = User(
        id: 'user-demo',
        name: 'Luna',
        email: AppConstants.demoEmail,
        averageCycleLength: AppConstants.defaultCycleLength,
        averagePeriodDuration: AppConstants.defaultPeriodDuration,
      );
      _accounts[demo.email] = _Account(demo, _hash(AppConstants.demoPassword));
    }
  }

  final Map<String, _Account> _accounts = {};
  User? _currentUser;

  static const Duration _fakeLatency = Duration(milliseconds: 500);

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(_fakeLatency);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.passwordHash != _hash(password)) {
      throw const AuthException('Incorrect email or password.');
    }
    _currentUser = account.user;
    return account.user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_fakeLatency);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    final user = User(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: key,
      averageCycleLength: AppConstants.defaultCycleLength,
      averagePeriodDuration: AppConstants.defaultPeriodDuration,
    );
    _accounts[key] = _Account(user, _hash(password));
    _currentUser = user;
    return user;
  }

  @override
  Future<User> updateUser(User user) async {
    final account = _accounts[user.email];
    if (account != null) account.user = user;
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  // Placeholder "hash" for the simulation only.
  String _hash(String value) => value.hashCode.toString();
}

class _Account {
  _Account(this.user, this.passwordHash);
  User user;
  final String passwordHash;
}
