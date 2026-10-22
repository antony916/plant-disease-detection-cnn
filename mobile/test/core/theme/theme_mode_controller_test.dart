import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/app.dart';
import 'package:plantcare_ai/core/theme/theme_scope.dart';
import 'package:plantcare_ai/core/theme/theme_mode_controller.dart';
import 'package:plantcare_ai/features/profile/profile_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('ThemeModeController defaults to system', () {
    final controller = ThemeModeController();
    expect(controller.mode, ThemeMode.system);
  });

  test('ThemeModeController changes mode and notifies listeners', () async {
    final controller = ThemeModeController();
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setMode(ThemeMode.light);
    expect(controller.mode, ThemeMode.light);
    await controller.setMode(ThemeMode.dark);
    expect(controller.mode, ThemeMode.dark);
    await controller.setMode(ThemeMode.system);
    expect(controller.mode, ThemeMode.system);
    expect(notifications, 3);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    test('ThemeModeController persists ${mode.name} across instances',
        () async {
      await ThemeModeController().setMode(mode);

      final restoredController = ThemeModeController();
      await restoredController.load();

      expect(restoredController.mode, mode);
    });
  }

  testWidgets('ThemeScope exposes and updates its controller', (tester) async {
    final controller = ThemeModeController();

    await tester.pumpWidget(
      ThemeScope(
        controller: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Text(ThemeScope.of(context).mode.name),
          ),
        ),
      ),
    );

    expect(find.text('system'), findsOneWidget);

    await controller.setMode(ThemeMode.dark);
    await tester.pump();

    expect(find.text('dark'), findsOneWidget);
  });

  testWidgets('Profile theme selection updates MaterialApp themeMode',
      (tester) async {
    final controller = ThemeModeController();

    await tester.pumpWidget(
      PlantCareApp(
        themeController: controller,
        home: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(SegmentedButton<ThemeMode>),
      300,
    );
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
