import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/core/theme/theme_mode_controller.dart';

void main() {
  testWidgets('ThemeModeController defaults to system', (tester) async {
    final controller = ThemeModeController();
    expect(controller.mode, ThemeMode.system);
  });

  testWidgets('ThemeModeController changes mode', (tester) async {
    final controller = ThemeModeController();
    await controller.setMode(ThemeMode.light);
    expect(controller.mode, ThemeMode.light);
    await controller.setMode(ThemeMode.dark);
    expect(controller.mode, ThemeMode.dark);
    await controller.setMode(ThemeMode.system);
    expect(controller.mode, ThemeMode.system);
  });
}
