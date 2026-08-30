import 'package:flutter/material.dart';

/// Paleta inspirada en tueste de café.
/// Nombrada por el proceso/producto, no genérica ("primary", "accent1"...).
class _CoffeePalette {
  // Modo claro
  static const oat = Color(0xFFEFE2CC); // fondo — leche de avena
  static const foam = Color(0xFFF8F1E3); // superficie (cards/inputs) — espuma
  static const espresso = Color(0xFF4A2E1E); // primario — tueste oscuro
  static const caramel = Color(0xFFB87A3D); // secundario — caramelo/canela

  // Modo oscuro
  static const darkRoast = Color(0xFF1C130D); // fondo — casi negro, tueste francés
  static const frenchPress = Color(0xFF2B1F16); // superficie
  static const latte = Color(0xFFDCB68E); // primario — tostado claro, buen contraste
  static const caramelDark = Color(0xFFD19A63); // secundario, aclarado para contraste

  // Compartidos
  static const errorLight = Color(0xFFB3261E);
  static const errorDark = Color(0xFFFFB4A9);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _CoffeePalette.espresso,
      onPrimary: _CoffeePalette.foam,
      secondary: _CoffeePalette.caramel,
      onSecondary: _CoffeePalette.foam,
      error: _CoffeePalette.errorLight,
      onError: Colors.white,
      surface: _CoffeePalette.foam,
      onSurface: _CoffeePalette.espresso,
      surfaceContainerHighest: _CoffeePalette.oat,
      outline: Color(0xFFB5A48C),
    );

    return _buildTheme(colorScheme, _CoffeePalette.oat);
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _CoffeePalette.latte,
      onPrimary: _CoffeePalette.darkRoast,
      secondary: _CoffeePalette.caramelDark,
      onSecondary: _CoffeePalette.darkRoast,
      error: _CoffeePalette.errorDark,
      onError: _CoffeePalette.darkRoast,
      surface: _CoffeePalette.frenchPress,
      onSurface: _CoffeePalette.oat,
      surfaceContainerHighest: Color(0xFF3A2A1D),
      outline: Color(0xFF6B584A),
    );

    return _buildTheme(colorScheme, _CoffeePalette.darkRoast);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Color scaffoldBackground) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.4);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}
