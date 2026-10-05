import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends ChangeNotifier {
  static const _key = 'plantcare_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final stored = await _preferences.getString(_key);
    _mode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _preferences.setString(
        _key,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        });
  }
}
