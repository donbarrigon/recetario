import 'package:flutter/material.dart';
import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';

class MeasurementUnitListVm extends ChangeNotifier {
  final MeasurementUnitRepository _repo = MeasurementUnitRepository();
  bool _isLoading;
  bool get isLoading => _isLoading;
  List<MeasurementUnit> _units;
  String _errorUnits;

  MeasurementUnitListVm({List<MeasurementUnit>? units}) : _units = units ?? [], _errorUnits = '', _isLoading = false;

  List<MeasurementUnit> get units => _units;
  String get errorUnits => _errorUnits;

  void getAll() {
    _isLoading = true;
    _errorUnits = '';
    try {
      _units = _repo.getAll();
    } catch (e) {
      _errorUnits = e.toString();
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  void delete(MeasurementUnit mu) {
    _isLoading = true;
    try {
      var wasDeleted = _repo.delete(mu);
      if (wasDeleted) {
        _units.remove(mu);
      } else {
        _errorUnits = 'La unidad ya no existe';
      }
    } catch (e) {
      _errorUnits = e.toString();
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }
}
