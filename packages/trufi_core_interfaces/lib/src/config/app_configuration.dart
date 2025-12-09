import 'trufi_screen.dart';
import 'trufi_theme_config.dart';
import 'trufi_locale_config.dart';

/// Application configuration
class AppConfiguration {
  final String appName;
  final List<TrufiScreen> screens;
  final TrufiLocaleConfig localeConfig;
  final TrufiThemeConfig themeConfig;

  const AppConfiguration({
    required this.appName,
    required this.screens,
    this.localeConfig = const TrufiLocaleConfig(),
    this.themeConfig = const TrufiThemeConfig(),
  });
}
