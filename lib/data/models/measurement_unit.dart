
class MeasurementUnit {
  final String id;           // ULID
  final int iconId;       // id del IconOPtion icono con de flutter
  final String symbol;       // g, ml, oz, etc
  final String name;         // gramo, mililitro, onza etc
  final bool isExact;        // true gramera, false ojo%
  final TypeUnit typeUnit;   // integer, float, fraction
  final String group;        // para agrupar
  final double scale;        // define la escala contra la unidad base del grupo
  final String description;  // texto de ayuda

  MeasurementUnit({
    required this.id,
    required this.iconId,
    required this.symbol,
    required this.name,
    required this.isExact,
    required this.typeUnit,
    required this.group,
    required this.scale,
    required this.description
  });

  factory MeasurementUnit.fromMap(Map<String, dynamic> map) {
    return MeasurementUnit(
      id: map['id'],
      iconId: map['iconId'],
      symbol: map['symbol'],
      name: map['name'],
      isExact: map['isExact'],
      typeUnit: TypeUnit.values.byName(map['typeUnit']),
      group: map['group'],
      scale: map['scale'],
      description: map['description']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iconId': iconId,
      'symbol': symbol,
      'name': name,
      'isExact': isExact,
      'typeUnit': typeUnit.name,
      'group': group,
      'scale': scale,
      'description': description
    };
  }

  MeasurementUnit copyWith({
    String? id,
    int? iconId,
    String? symbol,
    String? name,
    bool? isExact,
    TypeUnit? typeUnit,
    String? group,
    double? scale,
    String? description
  }) {
    return MeasurementUnit(
      id: id ?? this.id,
      iconId: iconId ?? this.iconId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      isExact: isExact ?? this.isExact,
      typeUnit: typeUnit ?? this.typeUnit,
      group: group ?? this.group,
      scale: scale ?? this.scale,
      description: description ?? this.description
    );
  }
}

enum TypeUnit {
  float,
  integer,
  fraction
}