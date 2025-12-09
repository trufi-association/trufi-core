import 'package:flutter/material.dart';

/// Theme extension data for a screen module
class ScreenThemeData {
  final Color? primaryColor;
  final Color? secondaryColor;
  final AppBarTheme? appBarTheme;
  final CardThemeData? cardTheme;
  final ElevatedButtonThemeData? elevatedButtonTheme;
  final List<ThemeExtension>? extensions;

  const ScreenThemeData({
    this.primaryColor,
    this.secondaryColor,
    this.appBarTheme,
    this.cardTheme,
    this.elevatedButtonTheme,
    this.extensions,
  });

  /// Merge this screen theme with a base theme
  ThemeData applyTo(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: primaryColor != null
          ? ColorScheme.fromSeed(
              seedColor: primaryColor!,
              secondary: secondaryColor,
            )
          : null,
      appBarTheme: appBarTheme ?? baseTheme.appBarTheme,
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme ?? baseTheme.elevatedButtonTheme,
      extensions: extensions ?? baseTheme.extensions.values,
    );
  }
}
