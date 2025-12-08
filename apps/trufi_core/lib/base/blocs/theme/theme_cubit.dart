import 'package:flutter/material.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart' as base;

// Re-export from trufi_core_base_widgets for backward compatibility
export 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart'
    show TrufiBaseTheme, TrufiBaseThemeHiveLocalRepository;

/// Extended ThemeCubit with localization support for display names.
class ThemeCubit extends base.ThemeCubit {
  ThemeCubit({required super.themeState});

  /// Returns a localized display name for the given theme mode.
  static String themeModeDisplayName(
    TrufiBaseLocalization localization,
    ThemeMode themeMode,
  ) {
    switch (themeMode) {
      case ThemeMode.system:
        return localization.themeModeSystem;
      case ThemeMode.light:
        return localization.themeModeLight;
      case ThemeMode.dark:
        return localization.themeModeDark;
    }
  }

  /// Checks if the given theme data is in dark mode.
  static bool isDarkMode(ThemeData themeData) {
    return base.ThemeCubit.isDarkMode(themeData);
  }
}
