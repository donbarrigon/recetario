import 'package:recetario/data/models/measurement_unit.dart';
import 'package:ulid/ulid.dart';
import 'package:hive/hive.dart';

class MeasurementUnitRepository {
  final String boxName = 'measurement_units';

  MeasurementUnitRepository();

  List<MeasurementUnit> getAll() {
    final box = Hive.box(name: boxName);
    var list = box.getAll(box.keys);
    return list.map((x) => MeasurementUnit.fromMap(Map<String, dynamic>.from(x))).toList();
  }

  MeasurementUnit? get(String key) {
    final box = Hive.box(name: boxName);
    var map = box.get(key);
    if (map == null) return null;
    return MeasurementUnit.fromMap(Map<String, dynamic>.from(map));
  }

  List<MeasurementUnit> getMany(List<String> keys) {
    final box = Hive.box(name: boxName);
    return box.getAll(keys).map((x) => MeasurementUnit.fromMap(Map<String, dynamic>.from(x))).toList();
  }

  bool symbolExists(String symbol, {String? excludeId}) {
    final box = Hive.box(name: boxName);
    return box.getAll(box.keys).any((x){
      var m = Map<String, dynamic>.from(x);
      return m['symbol'] == symbol && m['id'] != excludeId;
    }); 
  }

  bool nameExists(String name, {String? excludeId}) {
    final box = Hive.box(name: boxName);
    return box.getAll(box.keys).any((x){
      var m = Map<String, dynamic>.from(x);
      return m['name'] == name && m['id'] != excludeId;
    }); 
  }

  MeasurementUnit create(MeasurementUnit m) {
    var mu = m.copyWith(id: Ulid().toString());
    final box = Hive.box(name: boxName);
    box.put(mu.id, mu.toMap());
    return mu;
  }

  void update(MeasurementUnit m) {
    final box = Hive.box(name: boxName);
    box.put(m.id, m.toMap());
  }

  bool delete(MeasurementUnit m) {
    final box = Hive.box(name: boxName);
    return box.delete(m.id);
  }
}