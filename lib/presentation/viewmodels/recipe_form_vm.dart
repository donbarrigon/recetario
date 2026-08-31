import 'package:flutter/material.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/data/models/recipe_ingredient_item.dart';
import 'package:recetario/data/models/recipe_step.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:recetario/data/repositories/recipe_repository.dart';

class RecipeFormVm extends ChangeNotifier {
  FormAction _action;
  final RecipeRepository _repo = RecipeRepository();
  final RecipeIngredientRepository _repoIngredient = RecipeIngredientRepository();
  final MeasurementUnitRepository _repoMeasurementUnit = MeasurementUnitRepository();

  String _id;
  String _name;
  String _description;
  List<RecipeIngredientItem> _ingredients;
  List<RecipeStep> _steps;
  List<String> _tips;

  String _errorId;
  String _errorName;
  String _errorDescription;
  String _errorIngredients;
  String _errorSteps;
  String _errorTips;
  String _errorSave;

  RecipeFormVm({
    FormAction? action,
    String? id,
    String? name,
    String? description,
    List<RecipeIngredientItem>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tips,
  }) : _action = action ?? FormAction.show,
       _id = id ?? '',
       _name = name ?? '',
       _description = description ?? '',
       _ingredients = ingredients ?? [],
       _steps = steps ?? [],
       _tips = tips ?? [],
       _errorId = '',
       _errorName = '',
       _errorDescription = '',
       _errorIngredients = '',
       _errorSteps = '',
       _errorTips = '',
       _errorSave = '' {
    if (_id.isNotEmpty) _load();
  }

  // == LOAD ====================================================

  void _load() {
    var r = _repo.get(_id);
    if (r == null) {
      _errorId = 'No existe una receta con el id: [$_id]';
      return;
    }

    _name = r.name;
    _description = r.description;
    _ingredients = r.ingredients;
    _steps = r.steps;
    _tips = r.tips;
  }

  // == GETTERS ================================================

  FormAction get action => _action;
  String get id => _id;
  String get name => _name;
  String get description => _description;
  List<RecipeIngredientItem> get ingredients => _ingredients;
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

  set action(FormAction v) {
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

  set ingredients(List<RecipeIngredientItem> v) {
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

  // == VALIDATORS ===============================================

  void _validateId() {
    _errorId = '';
    if (_action == FormAction.update) {
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

    for (var item in _ingredients) {
      if (item.quantity <= 0) {
        _errorIngredients = 'La cantidad debe ser mayor a 0';
        return;
      }

      if (_repoIngredient.get(item.ingredientId) == null) {
        _errorIngredients = 'No existe un ingrediente con el id: [${item.ingredientId}]';
        return;
      }

      if (_repoMeasurementUnit.get(item.unitId) == null) {
        _errorIngredients = 'No existe una unidad de medida con el id: [${item.unitId}]';
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
      if (_errorSteps.isNotEmpty) return;
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

    if (_action == FormAction.show) {
      _errorSave = 'No se puede guardar la receta';
      notifyListeners();
      return;
    }

    var r = Recipe(
      id: _id,
      name: _name.trim(),
      description: _description.trim(),
      ingredients: _ingredients,
      steps: _steps,
      tips: _tips,
    );

    try {
      if (_action == FormAction.create) {
        r = _repo.create(r);
        _id = r.id;
      } else {
        _repo.update(r);
      }
      _errorSave = '';
      _action = FormAction.show;
    } catch (e) {
      _errorSave = e.toString();
    }
    notifyListeners();
  }

  void addIngredient(RecipeIngredientItem item) {
    _ingredients = [..._ingredients, item];
    _validateIngredients();
    notifyListeners();
  }

  void removeIngredientAt(int index) {
    if (index < 0 || index >= _ingredients.length) return;
    _ingredients = List.of(_ingredients)..removeAt(index);
    _validateIngredients();
    notifyListeners();
  }

  void addStep(RecipeStep step) {
    _steps = [..._steps, step];
    _validateSteps();
    notifyListeners();
  }

  void removeStepAt(int index) {
    if (index < 0 || index >= _steps.length) return;
    _steps = List.of(_steps)..removeAt(index);
    _validateSteps();
    notifyListeners();
  }
}
