import 'package:hive/hive.dart';
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
    var box = Hive.box(name: boxName);
    var list = box.getAll(box.keys).map((x) => Recipe.fromMap(Map<String, dynamic>.from(x))).toList();
    return list.map(_hydrate).toList();
  }

  Recipe? get(String key) {
    var box = Hive.box(name: boxName);
    var map = box.get(key);
    if (map == null) return null;
    var data = Recipe.fromMap(Map<String, dynamic>.from(map));
    return _hydrate(data);
  }

  List<Recipe> getMany(List<String> keys) {
    var box = Hive.box(name: boxName);
    var list = box.getAll(keys).map((x) => Recipe.fromMap(Map<String, dynamic>.from(x))).toList();
    return list.map(_hydrate).toList();
  }

  bool nameExists(String name, {String? excludeId}) {
    name = name.toLowerCase().trim();
    final box = Hive.box(name: boxName);
    return box.getAll(box.keys).any((x) {
      var m = Map<String, dynamic>.from(x);
      return m['name'] == name && m['id'] != excludeId;
    });
  }

  Recipe create(Recipe m) {
    var mu = m.copyWith(id: Ulid().toString());
    var box = Hive.box(name: boxName);
    box.put(mu.id, mu.toMap()); // ya no se remueve 'ingredients' — ahí vive la quantity
    return mu;
  }

  void update(Recipe m) {
    var box = Hive.box(name: boxName);
    box.put(m.id, m.toMap());
  }

  bool delete(Recipe m) {
    var box = Hive.box(name: boxName);
    return box.delete(m.id);
  }
}
