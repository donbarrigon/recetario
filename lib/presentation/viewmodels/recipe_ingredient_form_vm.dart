import 'package:flutter/material.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';

enum Action { show, create, update }

class RecipeIngredientFormVm extends ChangeNotifier {

  Action _action;
  final RecipeIngredientRepository _repo = RecipeIngredientRepository();

  String _id;                                    // ulid
  String _name;                                  // ingrediente
  // String _measureUnitId;                         // id unidad de medida base
  MeasurementUnit? _measureUnit;                 // unidad de medida para el hasOne
  // List<String> _measureUnitAvailableIds;         // ids de las unidades de medida disponibles
  List<MeasurementUnit> _measureUnitsAvailable; // unidades de medida disponibles para el hasMany
  String _description;                           // descripcion

  String _errorId;
  String _errorName;
  String _errorMeasureUnit;
  String _errorMeasureUnitsAvailable;
  String _errorDescription;
  String _errorSave;

  RecipeIngredientFormVm({
    Action? action,
    String? id,
    String? name,
    String? measureUnitId,
    MeasurementUnit? measureUnit,
    // List<String>? measureUnitAvailableIds,
    List<MeasurementUnit>? measureUnitsAvailable,
    String? description
  }) : _action = action ?? Action.show,
       _id = id ?? '',
       _name = name ?? '',
      //  _measureUnitId = measureUnitId ?? '',
      //  _measureUnit = measureUnit,
      //  _measureUnitAvailableIds = measureUnitAvailableIds ?? [],
       _measureUnitsAvailable = measureUnitsAvailable ?? [],
       _description = description ?? '',
       _errorId = '',
       _errorName = '',
       _errorMeasureUnit = '',
       _errorMeasureUnitsAvailable = '',
       _errorDescription = '',
       _errorSave = '';

  // == GETTERS ==================================================

  Action get action => _action;
  String get id => _id;
  String get name => _name;
  // String get measureUnitId => _measureUnitId;
  MeasurementUnit? get measureUnit => _measureUnit;
  // List<String> get measureUnitAvailableIds => _measureUnitAvailableIds;
  List<MeasurementUnit> get measureUnitsAvailable => _measureUnitsAvailable;
  String get description => _description;
  String get errorId => _errorId;
  String get errorName => _errorName;
  String get errorMeasureUnit => _errorMeasureUnit;
  String get errorMeasureUnitAvailables => _errorMeasureUnitsAvailable;
  String get errorDescription => _errorDescription;
  String get errorSave => _errorSave;

  // == SETTERS ==================================================

  set action(Action v) {
    if ( v == _action ) return;
    _action = v;
    notifyListeners();
  }

  set id(String v) {
    if ( v == _id ) return;
    var last = _errorId;
    _id = v;
    _validateId();
    if ( last != _errorId ) notifyListeners();
  }

  set name(String v) {
    if ( v == _name ) return;
    var last = _errorName;
    _name = v;
    _validateName();
    if ( last != _errorName ) notifyListeners();
  }

  set measureUnit(MeasurementUnit? v) {
    if ( v == _measureUnit ) return;
    var last = _errorMeasureUnit;
    _measureUnit = v;
    _validateMeasureUnit();
    if ( last != _errorMeasureUnit ) notifyListeners();
  }

  set measureUnitsAvailable(List<MeasurementUnit> v) {
    if ( v == _measureUnitsAvailable ) return;
    var last = _errorMeasureUnitsAvailable;
    _measureUnitsAvailable = v;
    _validateMeasureUnitsAvailable();
    if ( last != _errorMeasureUnitsAvailable ) notifyListeners();
  }

  set description(String v) {
    if ( v == _description ) return;
    var last = _errorDescription;
    _description = v;
    _validateDescription();
    if ( last != _errorDescription ) notifyListeners();
  }

  // == VALIDATORS ===============================================

  void _validateId() {
    if (_action == Action.update ){
      _repo.get(_id) == null ? _errorId = 'No existe un ingrediente con el id: [$_id]' : _errorId = '';
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

  void _validateMeasureUnit() {
    _errorMeasureUnit = '';
    if (_measureUnit == null) {
      _errorMeasureUnit = 'La unidad de medida es requerida';
      return;
    }

    var mur = MeasurementUnitRepository();
    if (mur.get(_measureUnit!.id) == null) {
      _errorMeasureUnit = 'No existe una unidad de medida con el id: [${_measureUnit!.id}]';
      return;
    }
  }

  void _validateMeasureUnitsAvailable() {
    _errorMeasureUnitsAvailable = '';
    if (_measureUnitsAvailable.isEmpty) {
      _errorMeasureUnitsAvailable = 'Almenos una unidad de medida habilitada es requerida';
      return;
    } 
    var mur = MeasurementUnitRepository();
    for (var mu in _measureUnitsAvailable) {
      if (mur.get(mu.id) == null) {
        _errorMeasureUnitsAvailable = 'No existe una unidad de medida con el id: [${mu.id}]';
        return;
      }
    }
  }

  void _validateDescription() =>_description.length > 255 ? _errorDescription = 'La descripción debe tener maximo 255 caracteres' : _errorDescription = '';

  /// return true if not has errors
  bool _validateAll() {
    _validateId();
    _validateName();
    _validateMeasureUnit();
    _validateMeasureUnitsAvailable();
    _validateDescription();
    return _errorId.isEmpty || 
      _errorName.isEmpty || 
      _errorMeasureUnit.isEmpty || 
      _errorMeasureUnitsAvailable.isEmpty || 
      _errorDescription.isEmpty;
  }

  // == METHODS ==================================================
  
  void save() {
    if (!_validateAll()) {
      _errorSave = 'Verifique los campos en rojo';
      notifyListeners();
      return;
    }

    if (_action == Action.show) {
      _errorSave = 'No se puede guardar el ingrediente';
      notifyListeners();
      return;
    }

    var ri = RecipeIngredient(
      id: _id,
      name: _name.trim(),
      measureUnitId: _measureUnit!.id,
      measureUnit: _measureUnit!,
      measureUnitAvailableIds: _measureUnitsAvailable.map((x) => x.id).toList(),
      measureUnitsAvailable: _measureUnitsAvailable,
      description: _description.trim()
    );

    try {
      if (_action == Action.create) {
        ri = _repo.create(ri);
        _id = ri.id;
      } else {
        _repo.update(ri);
      }
      _errorSave = '';
    } catch (e) {
      _errorSave = 'No se pudo guardar el ingrediente';
    }
    notifyListeners();
  }
}