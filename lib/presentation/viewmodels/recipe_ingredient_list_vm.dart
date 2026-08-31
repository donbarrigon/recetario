import 'package:flutter/material.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';

class RecipeIngredientListVm extends ChangeNotifier {
  final RecipeIngredientRepository _repo = RecipeIngredientRepository();

  bool _isLoading;
  List<RecipeIngredient> _ingredients;
  String _errorIngredients;
  RecipeIngredient? _selected;

  RecipeIngredientListVm({List<RecipeIngredient>? ingredients})
    : _ingredients = ingredients ?? [],
      _errorIngredients = '',
      _isLoading = false,
      _selected = null;

  bool get isLoading => _isLoading;
  List<RecipeIngredient> get ingredients => _ingredients;
  String get errorIngredients => _errorIngredients;
  RecipeIngredient? get selected => _selected;

  void select(RecipeIngredient ingredient) {
    _selected = (_selected?.id == ingredient.id) ? null : ingredient;
    notifyListeners();
  }

  void clearSelection() {
    if (_selected == null) return;
    _selected = null;
    notifyListeners();
  }

  void getAll() {
    _isLoading = true;
    _errorIngredients = '';
    notifyListeners();

    try {
      _ingredients = _repo.getAll();
    } catch (e) {
      _errorIngredients = e.toString();
    } finally {
      _isLoading = false;
    }
    _selected = null;
    notifyListeners();
  }

  void delete(RecipeIngredient ingredient) {
    _isLoading = true;
    try {
      var wasDeleted = _repo.delete(ingredient);
      if (wasDeleted) {
        _ingredients.remove(ingredient);
        if (_selected?.id == ingredient.id) _selected = null;
      } else {
        _errorIngredients = 'El ingrediente ya no existe';
      }
    } catch (e) {
      _errorIngredients = e.toString();
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }
}
