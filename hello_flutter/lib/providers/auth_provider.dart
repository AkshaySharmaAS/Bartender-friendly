import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/seed_data.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._storage);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    final initialized = await _storage.isInitialized();
    if (!initialized) {
      await _storage.saveUsers(SeedData.defaultUsers);
      await _storage.setInitialized();
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await _storage.getUsers();
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password &&
            u.role == role,
        orElse: () => throw Exception('Invalid credentials or role'),
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
