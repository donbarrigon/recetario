import 'package:hive_ce/hive_ce.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:ulid/ulid.dart';

class RecipeIngredientRepository {
  final String boxName = 'recipe_ingredients';
  final MeasurementUnitRepository _mur;

  RecipeIngredientRepository({MeasurementUnitRepository? measurementUnitRepository})
    : _mur = measurementUnitRepository ?? MeasurementUnitRepository();

  List<RecipeIngredient> getAll() {
    var box = Hive.box(boxName);
    var list = box.values.map((x) => RecipeIngredient.fromMap(Map<String, dynamic>.from(x))).toList();

    return list.map((item) {
      var lm = _mur.getMany(item.measureUnitAvailableIds);
      return item.copyWith(measureUnitAvailables: lm);
    }).toList();
  }

  RecipeIngredient? get(String key) {
    var box = Hive.box(boxName);
    var map = box.get(key);
    if (map == null) return null;
    var data = RecipeIngredient.fromMap(Map<String, dynamic>.from(map));
    var lm = _mur.getMany(data.measureUnitAvailableIds);
    return data.copyWith(measureUnitAvailables: lm);
  }

  List<RecipeIngredient> getMany(List<String> keys) {
    var box = Hive.box(boxName);
    var list = keys
        .map((x) => box.get(x))
        .where((x) => x != null)
        .map((x) => RecipeIngredient.fromMap(Map<String, dynamic>.from(x)))
        .toList();

    return list.map((item) {
      var lm = _mur.getMany(item.measureUnitAvailableIds);
      return item.copyWith(measureUnitAvailables: lm);
    }).toList();
  }

  Future<RecipeIngredient> create(RecipeIngredient m) async {
    var mu = m.copyWith(id: Ulid().toString());
    var box = Hive.box(boxName);
    var map = mu.toMap();
    map.remove('measureUnit');
    map.remove('measureUnitAvailables');
    await box.put(mu.id, map);
    return mu;
  }

  Future<void> update(RecipeIngredient m) async {
    var box = Hive.box(boxName);
    var map = m.toMap();
    map.remove('measureUnit');
    map.remove('measureUnitAvailables');
    await box.put(m.id, map);
  }

  Future<void> delete(RecipeIngredient m) async {
    var box = Hive.box(boxName);
    await box.delete(m.id);
  }
}
