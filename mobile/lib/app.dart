import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core/auth_gate.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/theme/theme_scope.dart';

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key, required this.themeController});

  final ThemeModeController themeController;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: MaterialApp(
        title: 'PlantCare AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.mode,
        builder: (context, child) {
          final brightness = Theme.of(context).brightness;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: brightness == Brightness.dark
                  ? PlantCareGradients.darkBackground
                  : PlantCareGradients.lightBackground,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const AuthGate(),
      ),
    );
  }
}
