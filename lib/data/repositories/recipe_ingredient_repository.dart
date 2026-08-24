import 'package:hive/hive.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:ulid/ulid.dart';

class RecipeIngredientRepository {
  final String boxName = 'recipe_ingredients';
  final MeasurementUnitRepository _mur;

  RecipeIngredientRepository({
    MeasurementUnitRepository? measurementUnitRepository
  }) : _mur = measurementUnitRepository ?? MeasurementUnitRepository();

  List<RecipeIngredient> getAll() {
    var box = Hive.box(name: boxName);
    var list = box.getAll(box.keys)
      .map((x) => RecipeIngredient.fromMap(Map<String, dynamic>.from(x)))
      .toList();

    return list.map((item) {
      var m = _mur.get(item.measureUnitId);
      var lm = _mur.getMany(item.measureUnitAvailableIds);
      return item.copyWith(measureUnit: m, measureUnitsAvailable: lm);
    }).toList();
  }

  RecipeIngredient? get(String key) {
    var box = Hive.box(name: boxName);
    var map = box.get(key);
    if (map == null) return null;
    var data = RecipeIngredient.fromMap(Map<String, dynamic>.from(map));
    var m = _mur.get(data.measureUnitId);
    var lm = _mur.getMany(data.measureUnitAvailableIds);
    return data.copyWith(measureUnit: m, measureUnitsAvailable: lm);
  }

  List<RecipeIngredient> getMany(List<String> keys) {
    var box = Hive.box(name: boxName);
    var list = box.getAll(keys)
      .map((x) => RecipeIngredient.fromMap(Map<String, dynamic>.from(x)))
      .toList();

    return list.map((item) {
      var m = _mur.get(item.measureUnitId);
      var lm = _mur.getMany(item.measureUnitAvailableIds);
      return item.copyWith(measureUnit: m, measureUnitsAvailable: lm);
    }).toList();
  }

  RecipeIngredient create(RecipeIngredient m) {
    var mu = m.copyWith(id: Ulid().toString());
    var box = Hive.box(name: boxName);
    var map = mu.toMap();
    map.remove('measureUnit');
    map.remove('measureUnitsAvailable');
    box.put(mu.id, map);
    return mu;
  }

  void update(RecipeIngredient m) {
    var box = Hive.box(name: boxName);
    var map = m.toMap();
    map.remove('measureUnit');
    map.remove('measureUnitsAvailable');
    box.put(m.id, map);
  }

  bool delete(RecipeIngredient m) {
    var box = Hive.box(name: boxName);
    return box.delete(m.id);
  }
}