import 'package:flutter/material.dart';
abstract final class PlantCareColors {
  // Brand
  static const lime = Color(0xFFA8E63D);
  static const limeGreen = Color(0xFF38B24A);
  static const primary = Color(0xFF176B3A);
  static const primaryDark = Color(0xFF0B2A1A);

  // Botanical backgrounds
  static const darkTop = Color(0xFF0B2A1A);
  static const darkMid = Color(0xFF14472A);
  static const darkBottom = Color(0xFF1F6A3A);
  static const lightTop = Color(0xFFF2FBF4);
  static const lightMid = Color(0xFFDDF3E4);
  static const lightBottom = Color(0xFFC8E9D2);

  // Text
  static const darkText = Color(0xFFF7FBF7);
  static const darkSecondary = Color(0xB3F7FBF7);
  static const lightText = Color(0xFF102217);
  static const lightSecondary = Color(0xFF486151);

  // Semantic
  static const danger = Color(0xFFFF7A7A);
  static const warning = Color(0xFFFFC857);
  static const success = Color(0xFF69D58B);
  static const info = Color(0xFF8DD6FF);
  static const white = Colors.white;
  static const black = Colors.black;

  // Legacy aliases kept temporarily while feature screens migrate to the
  // theme's ColorScheme and glass tokens.
  static const card = Color(0x1AFFFFFF);
  static const border = Color(0x2EFFFFFF);
  static const text = lightText;
  static const muted = lightSecondary;
  static const surface = lightTop;
  static const warm = Color(0x33FFC857);
  static const softGreen = Color(0x2638B24A);
  static const accent = lime;
}

abstract final class PlantCareGradients {
  static const darkBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PlantCareColors.darkTop,
      PlantCareColors.darkMid,
      PlantCareColors.darkBottom,
    ],
    stops: [0, 0.48, 1],
  );

  static const lightBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PlantCareColors.lightTop,
      PlantCareColors.lightMid,
      PlantCareColors.lightBottom,
    ],
    stops: [0, 0.5, 1],
  );

  static const lime = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [PlantCareColors.lime, PlantCareColors.limeGreen],
  );
}

abstract final class PlantCareSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const screen = 24.0;
}

abstract final class PlantCareRadius {
  static const card = 24.0;
  static const featured = 28.0;
  static const pill = 999.0;
}

abstract final class PlantCareGlass {
  static const blurSigma = 18.0;
  static const fillOpacity = 0.10;
  static const strongFillOpacity = 0.14;
  static const borderOpacity = 0.18;
  static const highlightOpacity = 0.16;
  static const shadowOpacity = 0.20;

  static Color fill(Color base, {bool strong = false}) =>
      base.withValues(alpha: strong ? strongFillOpacity : fillOpacity);

  static Color border(Color base) => base.withValues(alpha: borderOpacity);
  static Color highlight(Color base) =>
      base.withValues(alpha: highlightOpacity);
}

abstract final class PlantCareEffects {
  static bool reduced(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.disableAnimations || media.accessibleNavigation;
  }

  static double blurFor(BuildContext context) =>
      reduced(context) ? 0 : PlantCareGlass.blurSigma;
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PlantCareColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: PlantCareColors.primary,
      onPrimary: Colors.white,
      primaryContainer: PlantCareColors.lightBottom,
      onPrimaryContainer: PlantCareColors.lightText,
      secondary: PlantCareColors.limeGreen,
      onSecondary: PlantCareColors.black,
      secondaryContainer: PlantCareColors.lightMid,
      onSecondaryContainer: PlantCareColors.lightText,
      tertiary: PlantCareColors.limeGreen,
      onTertiary: PlantCareColors.black,
      surface: PlantCareColors.lightTop,
      onSurface: PlantCareColors.lightText,
      surfaceContainerLowest: Colors.white.withValues(alpha: 0.72),
      surfaceContainerLow: Colors.white.withValues(alpha: 0.80),
      surfaceContainer: Colors.white.withValues(alpha: 0.88),
      surfaceContainerHigh: Colors.white.withValues(alpha: 0.94),
      surfaceContainerHighest: Colors.white,
      onSurfaceVariant: PlantCareColors.lightSecondary,
      outline: PlantCareColors.primary.withValues(alpha: 0.20),
      outlineVariant: PlantCareColors.primary.withValues(alpha: 0.12),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
    );

    return _baseTheme(
      brightness: Brightness.light,
      scheme: scheme,
      foreground: PlantCareColors.lightText,
      secondaryForeground: PlantCareColors.lightSecondary,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PlantCareColors.limeGreen,
      brightness: Brightness.dark,
    ).copyWith(
      primary: PlantCareColors.lime,
      onPrimary: PlantCareColors.darkText,
      primaryContainer: PlantCareColors.primary,
      onPrimaryContainer: PlantCareColors.darkText,
      secondary: PlantCareColors.limeGreen,
      onSecondary: PlantCareColors.darkText,
      secondaryContainer: const Color(0xFF225A35),
      onSecondaryContainer: PlantCareColors.darkText,
      tertiary: PlantCareColors.lime,
      onTertiary: PlantCareColors.primaryDark,
      surface: PlantCareColors.darkTop,
      onSurface: PlantCareColors.darkText,
      surfaceContainerLowest: const Color(0xFF071D12),
      surfaceContainerLow: const Color(0xFF0D2E1C),
      surfaceContainer: const Color(0xFF123B23),
      surfaceContainerHigh: const Color(0xFF174A2A),
      surfaceContainerHighest: const Color(0xFF1D5832),
      onSurfaceVariant: PlantCareColors.darkSecondary,
      outline: Colors.white.withValues(alpha: 0.20),
      outlineVariant: Colors.white.withValues(alpha: 0.12),
      error: PlantCareColors.danger,
      onError: PlantCareColors.black,
    );

    return _baseTheme(
      brightness: Brightness.dark,
      scheme: scheme,
      foreground: PlantCareColors.darkText,
      secondaryForeground: PlantCareColors.darkSecondary,
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color foreground,
    required Color secondaryForeground,
  }) {
    final isDark = brightness == Brightness.dark;

    final baseTextTheme = TextTheme(
      displayLarge: const TextStyle(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: const TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w600,
      ),
    );
    final textTheme = baseTextTheme.apply(
      bodyColor: foreground,
      displayColor: foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      fontFamily: 'Inter',
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      splashColor: scheme.primary.withValues(alpha: 0.10),
      highlightColor: scheme.primary.withValues(alpha: 0.06),
      disabledColor: foreground.withValues(alpha: 0.38),
      dividerColor: scheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: foreground),
        iconTheme: IconThemeData(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.62),
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.card),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.68),
        hintStyle: TextStyle(color: secondaryForeground),
        labelStyle: TextStyle(color: secondaryForeground),
        prefixIconColor: secondaryForeground,
        suffixIconColor: secondaryForeground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.pill),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.pill),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.pill),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PlantCareSpacing.md,
          vertical: PlantCareSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PlantCareSpacing.lg,
            vertical: PlantCareSpacing.md,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PlantCareSpacing.lg,
            vertical: PlantCareSpacing.md,
          ),
          side: BorderSide(color: scheme.outline),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: foreground,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.62),
        selectedColor: scheme.primary,
        disabledColor: foreground.withValues(alpha: 0.08),
        labelStyle: textTheme.labelMedium?.copyWith(color: foreground),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: scheme.onPrimary),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: PlantCareSpacing.sm,
          vertical: PlantCareSpacing.xs,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : foreground.withValues(alpha: 0.78),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : foreground.withValues(alpha: 0.16),
        ),
        trackOutlineColor: WidgetStateProperty.all(scheme.outlineVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: foreground.withValues(alpha: 0.12),
        circularTrackColor: foreground.withValues(alpha: 0.12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.68),
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? const Color(0xEE10351F) : const Color(0xF2F4FBF5),
        modalBackgroundColor:
            isDark ? const Color(0xEE10351F) : const Color(0xF2F4FBF5),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? const Color(0xF2184228) : const Color(0xF2F4FBF5),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlantCareRadius.featured),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xF21A3022) : const Color(0xF2FFFFFF),
        contentTextStyle: textTheme.bodyMedium,
        shape: const StadiumBorder(),
        insetPadding: const EdgeInsets.fromLTRB(
          PlantCareSpacing.lg,
          PlantCareSpacing.sm,
          PlantCareSpacing.lg,
          PlantCareSpacing.lg,
        ),
      ),
    );
  }
}
