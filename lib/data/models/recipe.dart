import 'package:recetario/data/models/recipe_ingredient.dart';
import 'package:recetario/data/models/recipe_step.dart';

/// Recipe
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredientesIds;
  final List<RecipeIngredient>? ingredients;
  final List<RecipeStep> steps;
  final List<String> tips;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredientesIds,
    this.ingredients,
    required this.steps,
    required this.tips
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredientesIds: List<String>.from(map['ingredientesIds']),
      // ingredients: map['ingredients'] != null ? List<RecipeIngredient>.from(map['ingredients'].map((x) => RecipeIngredient.fromMap(x))) : null,
      ingredients: (map['ingredients'] as List<Map<String, dynamic>>?)?.map((x) => RecipeIngredient.fromMap(x)).toList(),
      steps: (map['steps'] as List<Map<String, dynamic>>? ?? []).map((x) => RecipeStep.fromMap(x)).toList(),
      tips: List<String>.from(map['tips'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredientesIds': ingredientesIds,
      'ingredients': ingredients,
      'steps': steps.map((x) => x.toMap()).toList(),
      'tips': tips
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredientesIds,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tips
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredientesIds: ingredientesIds ?? this.ingredientesIds,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips
    );
  }
}