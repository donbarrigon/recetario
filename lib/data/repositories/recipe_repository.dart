import 'package:hive_ce/hive_ce.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:recetario/data/repositories/measurement_unit_repository.dart';
import 'package:ulid/ulid.dart';

class RecipeRepository {
  final String boxName = 'recipes';
  final RecipeIngredientRepository _ir;
  final MeasurementUnitRepository _mur;

  RecipeRepository({
    RecipeIngredientRepository? ingredientRepository,
    MeasurementUnitRepository? measurementUnitRepository,
  }) : _ir = ingredientRepository ?? RecipeIngredientRepository(),
       _mur = measurementUnitRepository ?? MeasurementUnitRepository();

  Recipe _hydrate(Recipe r) {
    var hydratedItems = r.ingredients.map((item) {
      return item.copyWith(unit: _mur.get(item.unitId), ingredient: _ir.get(item.ingredientId));
    }).toList();
    return r.copyWith(ingredients: hydratedItems);
  }

  List<Recipe> getAll() {
    var box = Hive.box(boxName);
    var list = box.values.map((x) => Recipe.fromMap(Map<String, dynamic>.from(x))).toList();
    return list.map(_hydrate).toList();
  }

  Recipe? get(String key) {
    var box = Hive.box(boxName);
    var map = box.get(key);
    if (map == null) return null;
    var data = Recipe.fromMap(Map<String, dynamic>.from(map));
    return _hydrate(data);
  }

  List<Recipe> getMany(List<String> keys) {
    var box = Hive.box(boxName);
    var list = keys
        .map((x) => box.get(x))
        .where((x) => x != null)
        .map((x) => Recipe.fromMap(Map<String, dynamic>.from(x)))
        .toList();
    return list.map(_hydrate).toList();
  }

  bool nameExists(String name, {String? excludeId}) {
    name = name.toLowerCase().trim();
    final box = Hive.box(boxName);
    return box.values.any((x) {
      var m = Map<String, dynamic>.from(x);
      return m['name'] == name && m['id'] != excludeId;
    });
  }

  Future<Recipe> create(Recipe m) async {
    var mu = m.copyWith(id: Ulid().toString());
    var box = Hive.box(boxName);
    box.put(mu.id, mu.toMap());
    return mu;
  }

  Future<void> update(Recipe m) async {
    var box = Hive.box(boxName);
    box.put(m.id, m.toMap());
  }

  Future<void> delete(Recipe m) async {
    var box = Hive.box(boxName);
    return box.delete(m.id);
  }
}
