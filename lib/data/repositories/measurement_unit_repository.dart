import 'package:recetario/data/models/measurement_unit.dart';
import 'package:ulid/ulid.dart';
import 'package:hive_ce/hive_ce.dart';

class MeasurementUnitRepository {
  final String boxName = 'measurement_units';

  MeasurementUnitRepository();

  List<MeasurementUnit> getAll() {
    final box = Hive.box(boxName);
    return box.values.map((x) => MeasurementUnit.fromMap(Map<String, dynamic>.from(x))).toList();
  }

  MeasurementUnit? get(String key) {
    final box = Hive.box(boxName);
    var map = box.get(key);
    if (map == null) return null;
    return MeasurementUnit.fromMap(Map<String, dynamic>.from(map));
  }

  List<MeasurementUnit> getMany(List<String> keys) {
    final box = Hive.box(boxName);
    return keys
        .map((k) => box.get(k))
        .where((v) => v != null)
        .map((x) => MeasurementUnit.fromMap(Map<String, dynamic>.from(x)))
        .toList();
  }

  bool symbolExists(String symbol, {String? excludeId}) {
    final box = Hive.box(boxName);
    return box.values.any((x) {
      var m = Map<String, dynamic>.from(x);
      return m['symbol'] == symbol && m['id'] != excludeId;
    });
  }

  bool nameExists(String name, {String? excludeId}) {
    final box = Hive.box(boxName);
    return box.values.any((x) {
      var m = Map<String, dynamic>.from(x);
      return m['name'] == name && m['id'] != excludeId;
    });
  }

  Future<MeasurementUnit> create(MeasurementUnit m) async {
    var mu = m.copyWith(id: Ulid().toString());
    final box = Hive.box(boxName);
    await box.put(mu.id, mu.toMap());
    return mu;
  }

  Future<void> update(MeasurementUnit m) async {
    final box = Hive.box(boxName);
    await box.put(m.id, m.toMap());
  }

  Future<void> delete(MeasurementUnit m) async {
    final box = Hive.box(boxName);
    await box.delete(m.id);
  }
}
