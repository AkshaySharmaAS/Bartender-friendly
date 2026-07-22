import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._storage);

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final savedMode = await _storage.getThemeMode();
    if (savedMode != null) {
      _themeMode = savedMode;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storage.saveThemeMode(mode);
    notifyListeners();
  }
}
