import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive_ce/hive_ce.dart';
import 'package:recetario/data/models/recipe.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/models/measurement_unit.dart';

class ImportExportRepository {
  static const String _recipesBoxName = 'recipes';
  static const String _ingredientsBoxName = 'recipe_ingredients';
  static const String _unitsBoxName = 'measurement_units';

  /// Descarga el JSON semilla desde la URL https://raw.githubusercontent.com/donbarrigon/recetario/master/seed.json
  Future<Map<String, dynamic>> downloadSeed(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('No se pudo descargar el archivo (código ${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Parsea el contenido crudo de un archivo .json ya leído como texto
  Map<String, dynamic> parse(String jsonContent) {
    return jsonDecode(jsonContent) as Map<String, dynamic>;
  }

  /// Inserta el contenido del JSON en las boxes correspondientes.
  /// Preserva los ids originales del JSON para no romper las relaciones
  /// entre recetas, ingredientes y unidades de medida.
  Future<void> importData(Map<String, dynamic> data) async {
    var unitsBox = Hive.box(_unitsBoxName);
    var ingredientsBox = Hive.box(_ingredientsBoxName);
    var recipesBox = Hive.box(_recipesBoxName);

    // Orden importa: unidades -> ingredientes -> recetas, por las relaciones entre ellas.
    var units = (data['measurement_units'] as List? ?? []);
    for (var raw in units) {
      var unit = MeasurementUnit.fromMap(Map<String, dynamic>.from(raw));
      await unitsBox.put(unit.id, unit.toMap());
    }

    var ingredients = (data['recipe_ingredients'] as List? ?? []);
    for (var raw in ingredients) {
      var ingredient = RecipeIngredient.fromMap(Map<String, dynamic>.from(raw));
      var map = ingredient.toMap();
      map.remove('measureUnit');
      map.remove('measureUnitsAvailable');
      await ingredientsBox.put(ingredient.id, map);
    }

    var recipes = (data['recipes'] as List? ?? []);
    for (var raw in recipes) {
      var recipe = Recipe.fromMap(Map<String, dynamic>.from(raw));
      await recipesBox.put(recipe.id, recipe.toMap());
    }
  }

  /// Arma el mapa con el contenido actual de las tres boxes, en formato de exportación
  Map<String, dynamic> exportData() {
    var unitsBox = Hive.box(_unitsBoxName);
    var ingredientsBox = Hive.box(_ingredientsBoxName);
    var recipesBox = Hive.box(_recipesBoxName);

    return {
      'recipes': recipesBox.values.map((x) => Map<String, dynamic>.from(x)).toList(),
      'recipe_ingredients': ingredientsBox.values.map((x) => Map<String, dynamic>.from(x)).toList(),
      'measurement_units': unitsBox.values.map((x) => Map<String, dynamic>.from(x)).toList(),
    };
  }

  String exportToJsonString() {
    return const JsonEncoder.withIndent('  ').convert(exportData());
  }
}
