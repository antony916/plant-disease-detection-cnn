import 'package:flutter/material.dart';

abstract final class PlantCareColors {
  static const primary = Color(0xFF176B45);
  static const primaryDark = Color(0xFF0E4B31);
  static const secondary = Color(0xFF6FAE82);
  static const accent = Color(0xFFE6A23C);
  static const surface = Color(0xFFF7F8F4);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF18211C);
  static const muted = Color(0xFF66736A);
  static const border = Color(0xFFDCE3DD);
  static const danger = Color(0xFFC84C4C);
  static const warning = Color(0xFFC68A25);
  static const success = Color(0xFF2D8A58);
}

abstract final class PlantCareSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class PlantCareRadius {
  static const card = 16.0;
  static const featured = 20.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PlantCareColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: PlantCareColors.primary,
        secondary: PlantCareColors.secondary,
        surface: PlantCareColors.surface,
        error: PlantCareColors.danger,
      ),
      scaffoldBackgroundColor: PlantCareColors.surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: PlantCareColors.surface,
        foregroundColor: PlantCareColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: PlantCareColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.card),
          side: const BorderSide(color: PlantCareColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PlantCareColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PlantCareColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PlantCareColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PlantCareColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PlantCareSpacing.md,
          vertical: 15,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PlantCareColors.secondary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF101512),
    );
  }
}
