import 'package:flutter/material.dart';

import 'theme_mode_controller.dart';

class ThemeScope extends InheritedNotifier<ThemeModeController> {
  const ThemeScope({
    super.key,
    required ThemeModeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeModeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope is required above this context.');
    return scope!.notifier!;
  }
}
