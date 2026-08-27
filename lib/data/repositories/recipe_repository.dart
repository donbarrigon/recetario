import 'package:hive/hive.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/repositories/recipe_ingredient_repository.dart';
import 'package:ulid/ulid.dart';

class RecipeRepository {
  final String boxName = 'recipes';
  final RecipeIngredientRepository _ir;

  RecipeRepository({RecipeIngredientRepository? ingredientRepository}): _ir = ingredientRepository ?? RecipeIngredientRepository();

  List<Recipe> getAll() {
    var box = Hive.box(name: boxName);
    var list = box.getAll(box.keys).map((x) => Recipe.fromMap(Map<String, dynamic>.from(x))).toList();
    return list.map((l) => l.copyWith(ingredients: _ir.getMany(l.ingredientesIds))).toList();
  }

  Recipe? get(String key) {
    var box = Hive.box(name: boxName);
    var map = box.get(key);
    if (map == null) return null;
    var data = Recipe.fromMap(Map<String, dynamic>.from(map));
    return data.copyWith(ingredients: _ir.getMany(data.ingredientesIds));
  }
  
  List<Recipe> getMany(List<String> keys) {
    var box = Hive.box(name: boxName);
    var list = box.getAll(keys).map((x) => Recipe.fromMap(Map<String, dynamic>.from(x))).toList();
    return list.map((l) => l.copyWith(ingredients: _ir.getMany(l.ingredientesIds))).toList();
  }

  bool nameExists (String name, {String? excludeId}) {
    name = name.toLowerCase().trim();
    final box = Hive.box(name: boxName);
    return box.getAll(box.keys).any((x){
      var m = Map<String, dynamic>.from(x);
      return m['name'] == name && m['id'] != excludeId;
    });
  }

  Recipe create(Recipe m) {
    var mu = m.copyWith(id: Ulid().toString());
    var box = Hive.box(name: boxName);
    var map = mu.toMap();
    map.remove('ingredients');
    box.put(mu.id, map);
    return mu;
  }

  void update(Recipe m) {
    var box = Hive.box(name: boxName);
    var map = m.toMap();
    map.remove('ingredients');
    box.put(m.id, map);
  }

  bool delete(Recipe m) {
    var box = Hive.box(name: boxName);
    return box.delete(m.id);
  }
}