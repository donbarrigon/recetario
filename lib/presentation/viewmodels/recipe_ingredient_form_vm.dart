import 'package:flutter/material.dart';
import 'package:recetario/core/constants/form_action.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';

class RecipeIngredientFormVm extends ChangeNotifier {
  FormAction _action;
  final RecipeIngredientRepository _repo = RecipeIngredientRepository();
  final MeasurementUnitRepository _mur = MeasurementUnitRepository();

  String _id; // ulid
  int _iconId; // id del IconOption
  String _name; // ingrediente
  List<MeasurementUnit> _measureUnitAvailables; // unidades de medida disponibles para el hasMany
  String _description; // descripcion

  String _errorId;
  String _errorIconId;
  String _errorName;
  String _errorMeasureUnitAvailables;
  String _errorDescription;
  String _errorSave;

  RecipeIngredientFormVm({
    FormAction? action,
    String? id,
    int? iconId,
    String? name,
    List<MeasurementUnit>? measureUnitAvailables,
    String? description,
  }) : _action = action ?? FormAction.show,
       _id = id ?? '',
       _iconId = iconId ?? 0,
       _name = name ?? '',
       _measureUnitAvailables = measureUnitAvailables ?? [],
       _description = description ?? '',
       _errorId = '',
       _errorIconId = '',
       _errorName = '',
       _errorMeasureUnitAvailables = '',
       _errorDescription = '',
       _errorSave = '' {
    if (_id.isNotEmpty) _load();
  }

  void _load() {
    var ri = _repo.get(_id);
    if (ri == null) {
      _errorId = 'No existe un ingrediente con el id: [$_id]';
      return;
    }

    _iconId = ri.iconId;
    _name = ri.name;
    _measureUnitAvailables = ri.measureUnitAvailables ?? [];
    _description = ri.description;
  }

  // == GETTERS ==================================================

  FormAction get action => _action;
  String get id => _id;
  int get iconId => _iconId;
  String get name => _name;
  List<MeasurementUnit> get measureUnitAvailables => _measureUnitAvailables;
  String get description => _description;
  String get errorId => _errorId;
  String get errorIconId => _errorIconId;
  String get errorName => _errorName;
  String get errorMeasureUnitAvailables => _errorMeasureUnitAvailables;
  String get errorDescription => _errorDescription;
  String get errorSave => _errorSave;

  // == SETTERS ==================================================

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

  set iconId(int v) {
    if (v == _iconId) return;
    _iconId = v;
    _validateIconId();
    notifyListeners();
  }

  set name(String v) {
    if (v == _name) return;
    var last = _errorName;
    _name = v;
    _validateName();
    if (last != _errorName) notifyListeners();
  }

  set measureUnitAvailables(List<MeasurementUnit> v) {
    if (v == _measureUnitAvailables) return;
    _measureUnitAvailables = v;
    _validateMeasureUnitAvailables();
    notifyListeners();
  }

  set description(String v) {
    if (v == _description) return;
    var last = _errorDescription;
    _description = v;
    _validateDescription();
    if (last != _errorDescription) notifyListeners();
  }

  // == VALIDATORS ===============================================

  void _validateId() {
    _errorId = '';
    if (_action == FormAction.update) {
      if (_repo.get(_id) == null) {
        _errorId = 'No existe un ingrediente con el id: [$_id]';
      }
    }
  }

  void _validateIconId() {
    _errorIconId = '';
    if (!IconOption.exists(_iconId)) {
      _errorIconId = 'No existe un ícono con el id: [$_iconId]';
    }
  }

  void _validateName() {
    _errorName = '';
    if (_name.length > 50) {
      _errorName = 'El ingrediente debe tener maximo 50 caracteres';
      return;
    }
    if (_name.length < 3) {
      _errorName = 'El ingrediente debe tener al menos 3 caracteres';
      return;
    }
  }

  void _validateMeasureUnitAvailables() {
    _errorMeasureUnitAvailables = '';
    if (_measureUnitAvailables.isEmpty) {
      _errorMeasureUnitAvailables = 'Almenos una unidad de medida habilitada es requerida';
      return;
    }
    for (var mu in _measureUnitAvailables) {
      if (_mur.get(mu.id) == null) {
        _errorMeasureUnitAvailables = 'No existe una unidad de medida con el id: [${mu.id}]';
        return;
      }
    }
  }

  void _validateDescription() => _description.length > 255
      ? _errorDescription = 'La descripción debe tener maximo 255 caracteres'
      : _errorDescription = '';

  /// return true if not has errors
  bool _validateAll() {
    _validateId();
    _validateIconId();
    _validateName();
    _validateMeasureUnitAvailables();
    _validateDescription();
    return _errorId.isEmpty &&
        _errorIconId.isEmpty &&
        _errorName.isEmpty &&
        _errorMeasureUnitAvailables.isEmpty &&
        _errorDescription.isEmpty;
  }

  // == METHODS ==================================================

  Future<void> save() async {
    if (!_validateAll()) {
      _errorSave = 'Verifique los campos en rojo';
      notifyListeners();
      return;
    }

    if (_action == FormAction.show) {
      _errorSave = 'No se puede guardar el ingrediente';
      notifyListeners();
      return;
    }

    var ri = RecipeIngredient(
      id: _id,
      iconId: _iconId,
      name: _name.trim(),
      measureUnitAvailableIds: _measureUnitAvailables.map((x) => x.id).toList(),
      measureUnitAvailables: _measureUnitAvailables,
      description: _description.trim(),
    );

    try {
      if (_action == FormAction.create) {
        ri = await _repo.create(ri);
        _id = ri.id;
      } else {
        await _repo.update(ri);
      }
      _errorSave = '';
      _action = FormAction.show;
    } catch (e) {
      _errorSave = 'No se pudo guardar el ingrediente';
    }
    notifyListeners();
  }
}
