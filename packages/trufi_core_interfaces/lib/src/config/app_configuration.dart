import 'package:provider/single_child_widget.dart';

import 'trufi_screen.dart';
import 'trufi_theme_config.dart';
import 'trufi_locale_config.dart';
import 'social_media_config.dart';

/// Application configuration
class AppConfiguration {
  final String appName;
  final List<TrufiScreen> screens;
  final TrufiLocaleConfig localeConfig;
  final TrufiThemeConfig themeConfig;
  final List<SocialMediaLink> socialMediaLinks;

  /// Deep link scheme for route sharing (e.g., 'trufiapp').
  /// When set, shared routes will include a deep link URL that opens the app.
  final String? deepLinkScheme;

  /// Global providers that will be available to all screens.
  /// Use this to inject shared state like MapEngineManager, SavedPlacesCubit, etc.
  final List<SingleChildWidget> providers;

  const AppConfiguration({
    required this.appName,
    required this.screens,
    this.localeConfig = const TrufiLocaleConfig(),
    this.themeConfig = const TrufiThemeConfig(),
    this.socialMediaLinks = const [],
    this.deepLinkScheme,
    this.providers = const [],
  });
}
