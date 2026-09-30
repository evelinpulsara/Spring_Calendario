import 'package:flutter/foundation.dart';
import 'package:lunaflow/features/authentication/domain/entities/user.dart';
import 'package:lunaflow/features/authentication/domain/repositories/user_repository.dart';

/// Holds the logged-in user and exposes login / register / profile updates.
class SessionController extends ChangeNotifier {
  SessionController(this._repository);

  final UserRepository _repository;

  User? _user;
  bool _isBusy = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _user = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.register(name: name, email: email, password: password));
  }

  Future<void> updateProfile(User updated) async {
    _user = await _repository.updateUser(updated);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<User> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
