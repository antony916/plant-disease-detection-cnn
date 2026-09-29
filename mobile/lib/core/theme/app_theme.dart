import 'package:flutter/material.dart';

abstract final class PlantCareColors {
  static const primary = Color(0xFF176B3A);
  static const primaryDark = Color(0xFF0E4A2A);
  static const secondary = Color(0xFF4E8F5C);
  static const accent = Color(0xFFB7E36D);
  static const surface = Color(0xFFF7F9F5);
  static const card = Color(0xFFFFFFFF);
  static const softGreen = Color(0xFFE6F5E0);
  static const softBlue = Color(0xFFE6F5FF);
  static const warm = Color(0xFFFFF7E8);
  static const text = Color(0xFF171A18);
  static const muted = Color(0xFF68716B);
  static const border = Color(0xFFE2E7E2);
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
        onPrimary: Colors.white,
        secondary: PlantCareColors.secondary,
        surface: PlantCareColors.surface,
        error: PlantCareColors.danger,
      ),
      scaffoldBackgroundColor: PlantCareColors.surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: PlantCareColors.text,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
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
        hintStyle: const TextStyle(color: PlantCareColors.muted),
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
          borderSide:
              const BorderSide(color: PlantCareColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PlantCareColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PlantCareColors.primary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: PlantCareColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PlantCareColors.primary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 72,
        indicatorColor: PlantCareColors.softGreen,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PlantCareColors.text),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: PlantCareColors.muted, size: 22),
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
