import 'package:flutter/material.dart';
import 'package:recetario/core/theme/app_theme.dart';
import 'package:recetario/presentation/views/home_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}
