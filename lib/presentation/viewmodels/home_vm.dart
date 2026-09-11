import 'package:flutter/material.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';

class HomeVm extends ChangeNotifier {
  final RecipeRepository _repo = RecipeRepository();

  bool _isLoading;
  List<Recipe> _recipes;
  String _errorRecipes;
  String _query;

  HomeVm() : _recipes = [], _errorRecipes = '', _isLoading = false, _query = '';

  bool get isLoading => _isLoading;
  String get errorRecipes => _errorRecipes;
  String get query => _query;

  /// Lista filtrada por _query. Busca en nombre/descripción de la receta,
  /// nombre de cada ingrediente, y nombre de cada paso (incluidos sub-pasos).
  List<Recipe> get recipes {
    if (_query.isEmpty) return _recipes;
    var q = _query.toLowerCase();
    return _recipes.where((r) => _matches(r, q)).toList();
  }

  void search(String q) {
    if (q == _query) return;
    _query = q;
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
    notifyListeners();
  }

  bool _matches(Recipe r, String q) {
    if (r.name.toLowerCase().contains(q)) return true;
    if (r.description.toLowerCase().contains(q)) return true;

    for (var item in r.ingredients) {
      var name = item.ingredient?.name;
      if (name != null && name.toLowerCase().contains(q)) return true;
    }

    if (_stepsMatch(r.steps, q)) return true;

    return false;
  }

  bool _stepsMatch(List<RecipeStep> steps, String q) {
    for (var s in steps) {
      if (s.name.toLowerCase().contains(q)) return true;
      if (_stepsMatch(s.steps, q)) return true;
    }
    return false;
  }
}
