import 'package:recetario/data/models/recipe_ingredient_item.dart';
import 'package:recetario/data/models/recipe_step.dart';

/// Recipe
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeIngredientItem> ingredients;
  final List<RecipeStep> steps;
  final List<String> tips;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    List<RecipeIngredientItem>? ingredients,
    required this.steps,
    required this.tips,
  }) : ingredients = ingredients ?? [];

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: (map['ingredients'] as List? ?? [])
          .map((x) => RecipeIngredientItem.fromMap(Map<String, dynamic>.from(x)))
          .toList(),
      steps: (map['steps'] as List? ?? []).map((x) => RecipeStep.fromMap(Map<String, dynamic>.from(x))).toList(),
      tips: List<String>.from(map['tips'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'steps': steps.map((x) => x.toMap()).toList(),
      'tips': tips,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<RecipeIngredientItem>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tips,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
    );
  }
}
