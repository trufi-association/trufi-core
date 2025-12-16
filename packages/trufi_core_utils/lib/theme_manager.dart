import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current theme mode for the app with persistence
class ThemeManager extends ChangeNotifier {
  static const _storageKey = 'trufi_theme_mode';

  ThemeMode _themeMode;

  ThemeManager({ThemeMode defaultThemeMode = ThemeMode.system})
      : _themeMode = defaultThemeMode {
    _loadSavedTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_storageKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < ThemeMode.values.length) {
      final savedMode = ThemeMode.values[savedIndex];
      if (savedMode != _themeMode) {
        _themeMode = savedMode;
        notifyListeners();
      }
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _persistTheme(mode.index);
      notifyListeners();
    }
  }

  Future<void> _persistTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, index);
  }

  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isSystem => _themeMode == ThemeMode.system;

  static ThemeManager read(BuildContext context) => context.read<ThemeManager>();
  static ThemeManager watch(BuildContext context) => context.watch<ThemeManager>();
}
