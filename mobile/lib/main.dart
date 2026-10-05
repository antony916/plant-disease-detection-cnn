import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_services.dart';
import 'core/theme/theme_mode_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeModeController();
  await themeController.load();
  await AppServices.initialize();

  runApp(PlantCareApp(themeController: themeController));
}
