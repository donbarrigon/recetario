
import 'package:flutter/material.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';

enum Action { show, create, update }
class RecipeFormVm extends ChangeNotifier {

  Action _action;
  final RecipeRepository _repo = RecipeRepository();
  final RecipeIngredientRepository _repoIngredient = RecipeIngredientRepository();

  String _id;
  String _name;
  String _description;
  List<RecipeIngredient> _ingredients;
  List<RecipeStep> _steps;
  List<String> _tips;

  String _errorId;
  String _errorName;
  String _errorDescription;
  String _errorIngredients;
  String _errorSteps;
  String _errorTips;
  String _errorSave;

  RecipeFormVm ({
    Action? action,
    String? id,
    String? name,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tips
  }):
    _action = action ?? Action.show,
    _id = id ?? '',
    _name = name ?? '',
    _description = description ?? '',
    _ingredients = ingredients ?? [],
    _steps = steps ?? [],
    _tips = tips ?? [] ,
    _errorId = '',
    _errorName = '',
    _errorDescription = '',
    _errorIngredients = '',
    _errorSteps = '',
    _errorTips = '',
    _errorSave = '';

  // == GETTERS ================================================

  Action get action => _action;
  String get id => _id;
  String get name => _name;
  String get description => _description;
  List<RecipeIngredient> get ingredients => _ingredients;
  List<RecipeStep> get steps => _steps;
  List<String> get tips => _tips;
  String get errorId => _errorId;
  String get errorName => _errorName;
  String get errorDescription => _errorDescription;
  String get errorIngredients => _errorIngredients;
  String get errorSteps => _errorSteps;
  String get errorTips => _errorTips;
  String get errorSave => _errorSave;

  // == SETTERS ================================================

  set action(Action v) {
    if (v == _action) return;
    _action = v;
    notifyListeners();
  }

  set id(String v) {
    if (v == _id) return;
    var last = _errorId;
    _id = v;
    _validateId();
    if (last != _errorId) notifyListeners();
  }

  set name(String v) {
    if (v == _name) return;
    var last = _errorName;
    _name = v;
    _validateName();
    if (last != _errorName) notifyListeners();
  }

  set description(String v) {
    if (v == _description) return;
    var last = _errorDescription;
    _description = v;
    _validateDescription();
    if (last != _errorDescription) notifyListeners();
  }

  set ingredients(List<RecipeIngredient> v) {
    if (v == _ingredients) return;
    var last = _errorIngredients;
    _ingredients = v;
    _validateIngredients();
    if (last != _errorIngredients) notifyListeners();
  }

  set steps(List<RecipeStep> v) {
    if (v == _steps) return;
    var last = _errorSteps;
    _steps = v;
    _validateSteps();
    if (last != _errorSteps) notifyListeners();
  }

  set tips(List<String> v) {
    if (v == _tips) return;
    var last = _errorTips;
    _tips = v;
    _validateTips();
    if (last != _errorTips) notifyListeners();
  }

  // == VALIDATROS =============================================

  void _validateId() {
    _errorId = '';
    if (_action == Action.update)
    {
      if (_id.isEmpty) {
        _errorId = 'El id es requerido';
        return;
      }
      if (_repo.get(_id) == null) {
        _errorId = 'No existe una receta con el id: [$_id]';
      }
    }
  }

  void _validateName() {
    _errorName = '';
    if (_name.length > 100) {
      _errorName = 'Debe tener maximo 100 caracteres';
      return;
    }

    if (_name.length < 3) {
      _errorName = 'Debe tener al menos 3 caracteres';
      return;
    }

    if (_repo.nameExists(_name, excludeId: _id)) {
      _errorName = 'Ya existe una receta con el nombre: [$_name]';
      return;
    }
  }

  void _validateDescription() {
    _errorDescription = '';
    if (_description.length > 255) {
      _errorDescription = 'Debe tener maximo 255 caracteres';
      return;
    }
  }

  void _validateIngredients() {
    _errorIngredients = '';
    if (_ingredients.isEmpty) {
      _errorIngredients = 'Debe tener al menos un ingrediente';
      return;
    }

    for (var igredient in _ingredients) {
      if ( _repoIngredient.get(igredient.id) == null) {
        _errorIngredients = 'No existe un ingrediente con el id: [${igredient.id}]';
        return;
      }
    }
  }

  void _validateSteps() {
    _errorSteps = '';
    if (_steps.isEmpty) {
      _errorSteps = 'Debe tener al menos un paso';
      return;
    }

    for (int i = 0; i < _steps.length; i++) {
      _validateStep(_steps[i], '${i + 1}');
    }
  }

  void _validateStep(RecipeStep step, String idx) {
    if (step.name.isEmpty) {
      _errorSteps = 'El paso $idx debe tener un nombre';
      return;
    }

    if (step.name.length > 100) {
      _errorSteps = 'El paso $idx debe tener maximo 100 caracteres';
      return;
    }

    if (step.text.isEmpty) {
      _errorSteps = 'El paso $idx debe tener una descripcion';
      return;
    }

    if (step.text.length > 255) {
      _errorSteps = 'El paso $idx debe tener maximo 255 caracteres';
      return;
    }

    for (int i = 0; i < step.steps.length; i++) {
      _validateStep(step.steps[i], '$idx.${i + 1}');
      if (_errorSteps.isNotEmpty) return;
    }
  }

  void _validateTips() {
    _errorTips = '';
    for (var tip in _tips) {
      if (tip.length > 255) {
        _errorTips = 'Cada tip debe tener maximo 255 caracteres';
        return;
      }
    }
  }

  bool _validateAll() {
    _validateId();
    _validateName();
    _validateDescription();
    _validateIngredients();
    _validateSteps();
    _validateTips();
    return _errorId.isEmpty && 
      _errorName.isEmpty && 
      _errorDescription.isEmpty && 
      _errorIngredients.isEmpty && 
      _errorSteps.isEmpty && 
      _errorTips.isEmpty;
  }
  
  // == METHODS ================================================

  void save() {
    if (!_validateAll()) {
      _errorSave = 'Verifique los campos en rojo';
      notifyListeners();
      return;
    }

    if (_action == Action.show) {
      _errorSave = 'No se puede guardar la receta';
      notifyListeners();
      return;
    }

    var r = Recipe(
      id: _id,
      name: _name.trim(),
      description: _description.trim(),
      ingredientesIds: _ingredients.map((x) => x.id).toList(),
      ingredients: _ingredients,
      steps: _steps,
      tips: _tips
    );

    try {
      if (_action == Action.create) {
        r = _repo.create(r);
        _id = r.id;
      } else {
        _repo.update(r);
      }
      _errorSave = '';
      _action = Action.show;
    } catch (e) {
      _errorSave = e.toString();
    }
    notifyListeners();
  }

}