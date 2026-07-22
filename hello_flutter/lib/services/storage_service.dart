import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/drink.dart';
import '../models/customer_request.dart';

class StorageService {
  static const _usersKey = 'users';
  static const _drinksKey = 'drinks';
  static const _requestsKey = 'requests';
  static const _groqApiKeyKey = 'groq_api_key';
  static const _themeModeKey = 'theme_mode';
  static const _drinksVersionKey = 'drinks_version';
  static const _drinksVersion = 'v2'; // bump to force re-seed with new images
  static const _initializedKey = 'initialized';

  // ─── Users ───────────────────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  Future<void> removeUser(String id) async {
    final users = await getUsers();
    users.removeWhere((u) => u.id == id);
    await saveUsers(users);
  }

  // ─── Drinks ──────────────────────────────────────────────────────────────

  Future<List<Drink>> getDrinks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_drinksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Drink.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveDrinks(List<Drink> drinks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_drinksKey, jsonEncode(drinks.map((d) => d.toJson()).toList()));
  }

  Future<void> addDrink(Drink drink) async {
    final drinks = await getDrinks();
    drinks.add(drink);
    await saveDrinks(drinks);
  }

  Future<void> removeDrink(String id) async {
    final drinks = await getDrinks();
    drinks.removeWhere((d) => d.id == id);
    await saveDrinks(drinks);
  }

  Future<void> updateDrink(Drink updated) async {
    final drinks = await getDrinks();
    final idx = drinks.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      drinks[idx] = updated;
      await saveDrinks(drinks);
    }
  }

  // ─── Customer Requests ───────────────────────────────────────────────────

  Future<List<CustomerRequest>> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_requestsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => CustomerRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRequests(List<CustomerRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _requestsKey, jsonEncode(requests.map((r) => r.toJson()).toList()));
  }

  Future<void> addRequest(CustomerRequest request) async {
    final requests = await getRequests();
    requests.add(request);
    await saveRequests(requests);
  }

  Future<void> updateRequest(CustomerRequest updated) async {
    final requests = await getRequests();
    final idx = requests.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      requests[idx] = updated;
      await saveRequests(requests);
    }
  }

  // ─── API Key ─────────────────────────────────────────────────────────────

  Future<String?> getGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groqApiKeyKey);
  }

  Future<void> saveGroqApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groqApiKeyKey, key);
  }

  // ─── Theme mode ──────────────────────────────────────────────────────────

  Future<ThemeMode?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == null) return null;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  // ─── Init flag ───────────────────────────────────────────────────────────

  Future<bool> isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializedKey) ?? false;
  }

  Future<void> setInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initializedKey, true);
  }

  // ─── Drinks version (force re-seed when images/schema change) ────────────

  Future<bool> isDrinksVersionCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_drinksVersionKey) == _drinksVersion;
  }

  Future<void> setDrinksVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_drinksVersionKey, _drinksVersion);
  }
}
