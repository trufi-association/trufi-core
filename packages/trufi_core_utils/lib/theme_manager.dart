import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Manages the current theme mode for the app
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeManager({ThemeMode defaultThemeMode = ThemeMode.system})
      : _themeMode = defaultThemeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isSystem => _themeMode == ThemeMode.system;

  static ThemeManager read(BuildContext context) => context.read<ThemeManager>();
  static ThemeManager watch(BuildContext context) => context.watch<ThemeManager>();
}
