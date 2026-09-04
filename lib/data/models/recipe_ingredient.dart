import 'package:recetario/data/models/measurement_unit.dart';

class RecipeIngredient {
  final String id; // ulid
  final int iconId; // id del IconOPtion
  final String name; // ingrediente
  final List<String> measureUnitAvailableIds; // ids de las unidades de medida disponibles
  final List<MeasurementUnit>? measureUnitAvailables; // unidades de medida disponibles para el hasMany
  final String description; // descripcion

  RecipeIngredient({
    required this.id,
    required this.iconId,
    required this.name,
    required this.measureUnitAvailableIds,
    this.measureUnitAvailables,
    required this.description,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'],
      iconId: map['iconId'],
      name: map['name'],
      measureUnitAvailableIds: List<String>.from(map['measureUnitAvailableIds']),
      measureUnitAvailables: (map['measureUnitAvailables'] as List<Map<String, dynamic>>?)
          ?.map((x) => MeasurementUnit.fromMap(x))
          .toList(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iconId': iconId,
      'name': name,
      'measureUnitAvailableIds': measureUnitAvailableIds,
      'measureUnitAvailables': measureUnitAvailables,
      'description': description,
    };
  }

  RecipeIngredient copyWith({
    String? id,
    int? iconId,
    String? name,
    List<String>? measureUnitAvailableIds,
    List<MeasurementUnit>? measureUnitAvailables,
    String? description,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      iconId: iconId ?? this.iconId,
      name: name ?? this.name,
      measureUnitAvailableIds: measureUnitAvailableIds ?? this.measureUnitAvailableIds,
      measureUnitAvailables: measureUnitAvailables ?? this.measureUnitAvailables,
      description: description ?? this.description,
    );
  }
}
