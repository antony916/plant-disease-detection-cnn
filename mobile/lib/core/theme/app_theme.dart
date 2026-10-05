import 'package:flutter/material.dart';

abstract final class PlantCareColors {
  static const primary = Color(0xFF176B3A),
      primaryDark = Color(0xFF0E4A2A),
      accent = Color(0xFFB7E36D),
      surface = Color(0xFFF5F7F3),
      card = Colors.white,
      softGreen = Color(0xFFE8F3E8),
      softBlue = Color(0xFFEAF4FF),
      warm = Color(0xFFFFF7E8),
      text = Color(0xFF172019),
      muted = Color(0xFF68716B),
      border = Color(0xFFE1E6E1),
      danger = Color(0xFFC84C4C),
      warning = Color(0xFFC68A25),
      success = Color(0xFF2D8A58);
}

abstract final class PlantCareSpacing {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0, xl = 32.0;
}

abstract final class PlantCareRadius {
  static const card = 12.0, featured = 16.0, pill = 999.0;
}

class AppTheme {
  static ThemeData light() {
    final s = ColorScheme.fromSeed(
        seedColor: PlantCareColors.primary, brightness: Brightness.light);
    return ThemeData(
        useMaterial3: true,
        colorScheme: s.copyWith(
            primary: PlantCareColors.primary,
            onPrimary: Colors.white,
            secondary: PlantCareColors.primary,
            surface: PlantCareColors.surface,
            error: PlantCareColors.danger),
        scaffoldBackgroundColor: PlantCareColors.surface,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: PlantCareColors.text,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0),
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: PlantCareColors.border))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: PlantCareColors.muted),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: PlantCareColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: PlantCareColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide:
                    BorderSide(color: PlantCareColors.primary, width: 1.5)),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: PlantCareColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: PlantCareColors.primary,
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: PlantCareColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700))),
        navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 3,
            height: 68,
            indicatorColor: PlantCareColors.softGreen));
  }

  static ThemeData dark() => ThemeData.dark(useMaterial3: true);
}
