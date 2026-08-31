import 'package:flutter/material.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';

class RecipeListVm extends ChangeNotifier {
  final RecipeRepository _repo = RecipeRepository();

  bool _isLoading;
  List<Recipe> _recipes;
  String _errorRecipes;
  Recipe? _selected;
  String _query;

  RecipeListVm({List<Recipe>? recipes})
    : _recipes = recipes ?? [],
      _errorRecipes = '',
      _isLoading = false,
      _selected = null,
      _query = '';

  bool get isLoading => _isLoading;
  String get errorRecipes => _errorRecipes;
  Recipe? get selected => _selected;
  String get query => _query;

  /// Lista filtrada por _query (no expone la lista cruda a propósito)
  List<Recipe> get recipes {
    if (_query.isEmpty) return _recipes;
    var q = _query.toLowerCase();
    return _recipes.where((r) => r.name.toLowerCase().contains(q)).toList();
  }

  void search(String q) {
    if (q == _query) return;
    _query = q;
    notifyListeners();
  }

  void select(Recipe recipe) {
    _selected = (_selected?.id == recipe.id) ? null : recipe;
    notifyListeners();
  }

  void clearSelection() {
    if (_selected == null) return;
    _selected = null;
    notifyListeners();
  }

  void getAll() {
    _isLoading = true;
    _errorRecipes = '';
    notifyListeners();

    try {
      _recipes = _repo.getAll();
    } catch (e) {
      _errorRecipes = e.toString();
    } finally {
      _isLoading = false;
    }
    _selected = null;
    notifyListeners();
  }

  void delete(Recipe recipe) {
    _isLoading = true;
    try {
      var wasDeleted = _repo.delete(recipe);
      if (wasDeleted) {
        _recipes.remove(recipe);
        if (_selected?.id == recipe.id) _selected = null;
      } else {
        _errorRecipes = 'La receta ya no existe';
      }
    } catch (e) {
      _errorRecipes = e.toString();
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }
}
