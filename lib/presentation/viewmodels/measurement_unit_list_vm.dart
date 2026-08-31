import 'package:flutter/material.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';

class MeasurementUnitListVm extends ChangeNotifier {
  final MeasurementUnitRepository _repo = MeasurementUnitRepository();
  bool _isLoading;
  bool get isLoading => _isLoading;
  Map<String, List<MeasurementUnit>> _units;
  String _errorUnits;
  MeasurementUnit? _selected;

  MeasurementUnitListVm({Map<String, List<MeasurementUnit>>? units})
    : _units = units ?? {},
      _errorUnits = '',
      _isLoading = false,
      _selected = null;

  Map<String, List<MeasurementUnit>> get units => _units;
  String get errorUnits => _errorUnits;
  MeasurementUnit? get selected => _selected;

  void select(MeasurementUnit unit) {
    // toca de nuevo el mismo item -> deselecciona
    _selected = (_selected?.id == unit.id) ? null : unit;
    notifyListeners();
  }

  void clearSelection() {
    if (_selected == null) return;
    _selected = null;
    notifyListeners();
  }

  void getAll() {
    _isLoading = true;
    _errorUnits = '';
    notifyListeners();

    List<MeasurementUnit> list = [];
    try {
      list = _repo.getAll();
    } catch (e) {
      _errorUnits = e.toString();
    } finally {
      _isLoading = false;
    }

    Map<String, List<MeasurementUnit>> map = {};
    for (var item in list) {
      map.putIfAbsent(item.group, () => []).add(item);
    }
    _units = map;
    _selected = null; // al recargar, la selección anterior ya no aplica
    notifyListeners();
  }

  Future<void> delete(MeasurementUnit mu) async {
    _isLoading = true;
    try {
      await _repo.delete(mu);
      _units[mu.group]?.remove(mu);
      if (_units[mu.group]?.isEmpty ?? false) {
        _units.remove(mu.group);
      }
      if (_selected?.id == mu.id) _selected = null;
    } catch (e) {
      _errorUnits = e.toString();
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }
}
