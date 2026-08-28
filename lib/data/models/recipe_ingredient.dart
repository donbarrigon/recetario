import 'package:recetario/data/models/measurement_unit.dart';

class RecipeIngredient{
  final String id;                                    // ulid
  final String name;                                  // ingrediente
  final String measureUnitId;                         // id unidad de medida base
  final MeasurementUnit? measureUnit;                 // unidad de medida para el hasOne
  final List<String> measureUnitAvailableIds;         // ids de las unidades de medida disponibles
  final List<MeasurementUnit>? measureUnitAvailables; // unidades de medida disponibles para el hasMany
  final String description;                           // descripcion

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.measureUnitId,
    this.measureUnit,
    required this.measureUnitAvailableIds,
    this.measureUnitAvailables,
    required this.description
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'],
      name: map['name'],
      measureUnitId: map['measureUnitId'],
      measureUnit: map['measureUnit'],
      measureUnitAvailableIds: List<String>.from(map['measureUnitAvailableIds']),
      measureUnitAvailables: (map['measureUnitAvailables'] as List<Map<String, dynamic>>?)?.map((x) => MeasurementUnit.fromMap(x)).toList(),
      description: map['description']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'measureUnitId': measureUnitId,
      'measureUnit': measureUnit,
      'measureUnitAvailableIds': measureUnitAvailableIds,
      'measureUnitAvailables': measureUnitAvailables,
      'description': description
    };
  }

  RecipeIngredient copyWith({
    String? id,
    String? name,
    String? measureUnitId,
    MeasurementUnit? measureUnit,
    List<String>? measureUnitAvailableIds,
    List<MeasurementUnit>? measureUnitAvailables,
    String? description
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      measureUnitId: measureUnitId ?? this.measureUnitId,
      measureUnit: measureUnit ?? this.measureUnit,
      measureUnitAvailableIds: measureUnitAvailableIds ?? this.measureUnitAvailableIds,
      measureUnitAvailables: measureUnitAvailables ?? this.measureUnitAvailables,
      description: description ?? this.description
    );
  }
}