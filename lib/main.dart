import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:recetario/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final dir = await getApplicationDocumentsDirectory();
  // Hive.defaultDirectory = dir.path;
  await Hive.initFlutter();
  await Hive.openBox('recipes');
  await Hive.openBox('recipe_ingredients');
  await Hive.openBox('measurement_units');
  runApp(const MyApp());
}
