import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../services/storage_service.dart';
import '../services/seed_data.dart';

class DrinkProvider extends ChangeNotifier {
  final StorageService _storage;

  List<Drink> _drinks = [];
  bool _isLoading = false;

  DrinkProvider(this._storage);

  List<Drink> get drinks => List.unmodifiable(_drinks);
  bool get isLoading => _isLoading;

  List<Drink> get cocktails =>
      _drinks.where((d) => d.type == DrinkType.cocktail).toList();

  List<Drink> get mocktails =>
      _drinks.where((d) => d.type == DrinkType.mocktail).toList();

  List<Drink> get popularDrinks =>
      _drinks.where((d) => d.isPopular).toList();

  Future<void> loadDrinks() async {
    _isLoading = true;
    notifyListeners();

    var stored = await _storage.getDrinks();
    if (stored.isEmpty) {
      stored = SeedData.popularDrinks;
      await _storage.saveDrinks(stored);
    }
    _drinks = stored;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDrink(Drink drink) async {
    await _storage.addDrink(drink);
    _drinks.add(drink);
    notifyListeners();
  }

  Future<void> removeDrink(String id) async {
    await _storage.removeDrink(id);
    _drinks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> updateDrink(Drink updated) async {
    await _storage.updateDrink(updated);
    final idx = _drinks.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      _drinks[idx] = updated;
      notifyListeners();
    }
  }

  List<Drink> search(String query) {
    final q = query.toLowerCase();
    return _drinks
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.ingredients.any((i) => i.toLowerCase().contains(q)))
        .toList();
  }
}
