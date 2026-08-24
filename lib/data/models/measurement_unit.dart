
class MeasurementUnit {
  final String id;           // ULID
  final String iconName;    // icono de flutter
  final String symbol;       // g, ml, oz, etc
  final String name;         // gramo, mililitro, onza etc
  final bool isExact;        // true gramera, false ojo%
  final TypeUnit typeUnit;   // integer, float, fraction
  final String group;        // para agrupar
  final bool isBase;         // define si es la base del grupo
  final double scale;        // define la escala contra la unidad base del grupo
  final String description;  // texto de ayuda

  MeasurementUnit({
    required this.id,
    required this.iconName,
    required this.symbol,
    required this.name,
    required this.isExact,
    required this.typeUnit,
    required this.group,
    required this.isBase,
    required this.scale,
    required this.description
  });

  factory MeasurementUnit.fromMap(Map<String, dynamic> map) {
    return MeasurementUnit(
      id: map['id'],
      iconName: map['iconName'],
      symbol: map['symbol'],
      name: map['name'],
      isExact: map['isExact'],
      typeUnit: TypeUnit.values.byName(map['typeUnit']),
      group: map['group'],
      isBase: map['isBase'],
      scale: map['scale'],
      description: map['description']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iconName': iconName,
      'symbol': symbol,
      'name': name,
      'isExact': isExact,
      'typeUnit': typeUnit.name,
      'group': group,
      'isBase': isBase,
      'scale': scale,
      'description': description
    };
  }

  MeasurementUnit copyWith({
    String? id,
    String? iconName,
    String? symbol,
    String? name,
    bool? isExact,
    TypeUnit? typeUnit,
    String? group,
    bool? isBase,
    double? scale,
    String? description
  }) {
    return MeasurementUnit(
      id: id ?? this.id,
      iconName: iconName ?? this.iconName,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      isExact: isExact ?? this.isExact,
      typeUnit: typeUnit ?? this.typeUnit,
      group: group ?? this.group,
      isBase: isBase ?? this.isBase,
      scale: scale ?? this.scale,
      description: description ?? this.description
    );
  }
}

enum TypeUnit {
  integer,
  float,
  fraction
}