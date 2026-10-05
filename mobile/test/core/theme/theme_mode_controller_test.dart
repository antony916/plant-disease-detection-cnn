import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/core/theme/theme_mode_controller.dart';
import 'package:plantcare_ai/core/theme/theme_scope.dart';
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

  test('ThemeModeController changes mode, notifies, and persists', () async {
    final controller = ThemeModeController();
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setMode(ThemeMode.light);

    expect(controller.mode, ThemeMode.light);
    expect(notifications, 1);

    final reloaded = ThemeModeController();
    await reloaded.load();

    expect(reloaded.mode, ThemeMode.light);
  });

  test('ThemeModeController reads a saved value on a new controller', () async {
    final controller = ThemeModeController();
    await controller.setMode(ThemeMode.dark);

    final reloaded = ThemeModeController();
    await reloaded.load();

    expect(reloaded.mode, ThemeMode.dark);
  });

  testWidgets('Profile theme selector changes MaterialApp themeMode',
      (tester) async {
    final controller = ThemeModeController();

    await tester.pumpWidget(
      ThemeScope(
        controller: controller,
        child: _TestApp(controller: controller),
      ),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await tester.tap(find.text('Light'));
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.controller});

  final ThemeModeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: controller.mode,
          home: const ProfileScreen(),
        );
      },
    );
  }
}
