import 'package:flutter/material.dart';

/// Theme configuration
class TrufiThemeConfig {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  const TrufiThemeConfig({
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
  });
}
