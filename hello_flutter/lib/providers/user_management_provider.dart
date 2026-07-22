import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final StorageService _storage;

  List<User> _users = [];
  bool _isLoading = false;

  UserManagementProvider(this._storage);

  List<User> get users => List.unmodifiable(_users);
  List<User> get bartenders =>
      _users.where((u) => u.role == UserRole.bartender).toList();
  List<User> get customers =>
      _users.where((u) => u.role == UserRole.customer).toList();
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    _users = await _storage.getUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await _storage.addUser(user);
    _users.add(user);
    notifyListeners();
  }

  Future<void> removeUser(String id) async {
    await _storage.removeUser(id);
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
