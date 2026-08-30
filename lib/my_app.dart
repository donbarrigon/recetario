import 'package:flutter/material.dart';
import 'package:recetario/presentation/views/measurement_unit/form.dart';
import 'package:recetario/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MeasurementUnitFormView(),
    );
  }
}
