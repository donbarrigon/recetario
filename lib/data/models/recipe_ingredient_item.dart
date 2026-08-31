import 'package:recetario/data/models/measurement_unit.dart';
import 'package:recetario/data/models/recipe_ingredient.dart';

class RecipeIngredientItem {
  final int quantity;
  final String unitId;
  final MeasurementUnit? unit;
  final String ingredientId;
  final RecipeIngredient? ingredient;

  RecipeIngredientItem({int? quantity, required this.unitId, this.unit, required this.ingredientId, this.ingredient})
    : quantity = quantity ?? 0;

  factory RecipeIngredientItem.fromMap(Map<String, dynamic> map) {
    return RecipeIngredientItem(
      quantity: map['quantity'] ?? 0,
      unitId: map['unitId'] ?? '',
      ingredientId: map['ingredientId'] ?? '',
      // unit e ingredient NO se hidratan aquí — lo hace RecipeRepository después
    );
  }

  Map<String, dynamic> toMap() {
    return {'quantity': quantity, 'unitId': unitId, 'ingredientId': ingredientId};
  }

  RecipeIngredientItem copyWith({
    int? quantity,
    String? unitId,
    MeasurementUnit? unit,
    String? ingredientId,
    RecipeIngredient? ingredient,
  }) {
    return RecipeIngredientItem(
      quantity: quantity ?? this.quantity,
      unitId: unitId ?? this.unitId,
      unit: unit ?? this.unit,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredient: ingredient ?? this.ingredient,
    );
  }
}
