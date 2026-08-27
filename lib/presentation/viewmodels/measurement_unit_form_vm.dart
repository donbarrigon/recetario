import 'package:flutter/foundation.dart';
import 'package:recetario/core/constants/icon_option.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';

enum Action { show, create, update }
class MeasurementUnitFormVm extends ChangeNotifier{
  Action _action;
  final _repo = MeasurementUnitRepository();

  String _id;           // ULID
  int _iconId;     // icono de flutter
  String _symbol;       // g, ml, oz, etc
  String _name;         // gramo, mililitro, onza etc
  bool _isExact;        // true gramera, false ojo%
  TypeUnit _typeUnit;   // integer, float, fraction
  String _group;        // para agrupar
  double _scale;        // define la escala contra la unidad base del grupo
  String _description;  // texto de ayuda

  String _errorId;
  String _errorIconId;
  String _errorSymbol;
  String _errorName;
  // String _errorIsExact;
  // String _errorTypeUnit;
  String _errorGroup;
  String _errorScale;
  String _errorDescription;
  String _errorSave;

// == CONSTRUCTOR ==============================================
  MeasurementUnitFormVm({
    Action? action,
    String? id,
    int? iconId,
    String? symbol,
    String? name,
    bool? isExact,
    TypeUnit? typeUnit,
    String? group,
    double? scale,
    String? description
  }): _action = action ?? Action.show, 
      _id = id ?? '',
      _iconId = iconId ?? 0,
      _symbol = symbol ?? '',
      _name = name ?? '',
      _isExact = isExact ?? false,
      _typeUnit = typeUnit ?? TypeUnit.integer,
      _group = group ?? '',
      _scale = scale ?? 1.0,
      _description = description ?? '',
      _errorId = '',
      _errorIconId = '',
      _errorSymbol = '',
      _errorName = '',
      // _errorIsExact = '',
      // _errorTypeUnit = '',
      _errorGroup = '',
      _errorScale = '',
      _errorDescription = '',
      _errorSave = '';

// == GETTERS ==================================================

  Action get action => _action;
  String get id => _id;
  int get iconId => _iconId;
  String get symbol => _symbol;
  String get name => _name;
  bool get isExact => _isExact;
  TypeUnit get typeUnit => _typeUnit;
  String get group => _group;
  double get scale => _scale;
  String get description => _description;

  String get errorId => _errorId;
  String get errorIconId => _errorIconId;
  String get errorSymbol => _errorSymbol;
  String get errorName => _errorName;
  // String get errorIsExact => _errorIsExact;
  // String get errorTypeUnit => _errorTypeUnit;
  String get errorGroup => _errorGroup;
  String get errorScale => _errorScale;
  String get errorDescription => _errorDescription;
  String get errorSave => _errorSave;

  // == SETTERS ==================================================

  set id(String v) {
    if (v == _id) return;
    _id = v;
    _validateId();
    notifyListeners();
  }

  set iconId(int id) {
    if (id == _iconId) return;
    _iconId = id;
    _validateIconId();
    notifyListeners();
  }
  
  set symbol(String s) {
    if (s == _symbol) return;
    _symbol = s.toLowerCase().trim();
    _validateSymbol();
    notifyListeners();
  }
  
  set name(String n) {
    if (n == _name) return;
    _name = n;
    _validateName();
    notifyListeners();
  }
  
  set isExact(bool v) {
    if (v == _isExact) return;
    _isExact = v;
    notifyListeners();
  }

  set typeUnit(TypeUnit v) {
    if (v == _typeUnit) return;
    _typeUnit = v;
    notifyListeners();
  }
  
  set group(String g) {
    if (g == _group) return;
    _group = g;
    _validateGroup();
    notifyListeners();
  }

  set scale(double v) {
    if (v == _scale) return;
    _scale = v;
    _validateScale();
    notifyListeners();
  }

  set description(String d) {
    if (d == _description) return;
    _description = d;
    _validateDescription();
    notifyListeners();
  }

  // == VALIDATORS ===============================================

  void _validateId() {
    _errorId = '';
    if (_action == Action.update)
    {
      if (_id.isEmpty) _errorId = 'El id es requerido';
      if (_repo.get(_id) == null) {
        _errorId = 'No existe una unidad de medida con el id: [$_id]';
      }
    }
  }

  void _validateIconId() {
    _errorIconId = '';
    if (!IconOption.exists(_iconId)) _errorIconId = 'No existe un icono con el id: [$_iconId]';
  }

  void _validateSymbol() {
    _errorSymbol = '';
    if (_symbol.isEmpty) {
      _errorSymbol = 'El simbolo [$_symbol] debe tener al menos 1 caracter';
      return;
    }

    if (_symbol.length > 5) {
      _errorSymbol = 'El simbolo [$_symbol] debe tener maximo 5 caracteres';
      return;
    }

    if (_repo.symbolExists(_symbol, excludeId: _id)) {
      _errorSymbol = 'Ya existe una unidad de medida con el simbolo: [$_symbol]';
      return;
    }
  }

  void _validateName() {
    _errorName = '';
    if (_name.length < 3) {
      _errorName = 'El nombre debe tener al menos 3 caracteres';
      return;
    }

    if (_name.length > 50) {
      _errorName = 'El nombre debe tener maximo 50 caracteres';
      return;
    }

    if (_repo.nameExists(_name, excludeId: _id)) {
      _errorName = 'Ya existe una unidad de medida con el nombre: [$_name]';
      return;
    }
  }

  void _validateGroup() {
    _errorGroup = '';
    if (_group.length < 3) {
      _errorGroup = 'El grupo debe tener al menos 3 caracteres';
      return;
    }

    if (_group.length > 50) {
      _errorGroup = 'El grupo debe tener maximo 50 caracteres';
      return;
    }
  }

  void _validateScale() {
    _errorScale = '';
    if (_scale == 0) _errorScale = 'La escala debe ser diferente a 0';
  }

  void _validateDescription() {
    _errorDescription = '';
    if (_description.length > 255) _errorDescription = 'La descripcion debe tener maximo 255 caracteres';
  }

  /// return true if not has errors
  bool _validateAll() {
    _validateId();
    _validateIconId();
    _validateSymbol();
    _validateName();
    _validateGroup();
    _validateScale();
    _validateDescription();
    return _errorId.isEmpty && 
      _errorIconId.isEmpty && 
      _errorSymbol.isEmpty && 
      _errorName.isEmpty && 
      _errorGroup.isEmpty && 
      _errorScale.isEmpty && 
      _errorDescription.isEmpty;
  }

  // == ACTIONS ==================================================

  void save() {
    if (!_validateAll()) {
      _errorSave = 'Verifique los campos en rojo';
      notifyListeners();
      return;
    }

    if (_action == Action.show) {
      _errorSave = 'No se pudo guardar la unidad de medida';
      notifyListeners();
      return;
    }

    var m = MeasurementUnit(
      id: _id,
      iconId: _iconId,
      symbol: _symbol.toLowerCase().trim(),
      name: _name.trim(),
      isExact: _isExact,
      typeUnit: _typeUnit,
      group: _group.toLowerCase().trim(),
      scale: _scale,
      description: _description.trim()
    );

    try {
      if (_action == Action.create) {
        m =_repo.create(m);
        _id = m.id;
      } else {
        _repo.update(m);
      }
      _errorSave = '';
      _action = Action.show;
    } catch (e) {
      _errorSave = 'Error al guardar la unidad de medida: ${e.toString()}';
    }
    
    notifyListeners();
  }
}