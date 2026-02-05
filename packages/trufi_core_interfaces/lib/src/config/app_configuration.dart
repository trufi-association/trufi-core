import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'trufi_screen.dart';
import 'trufi_theme_config.dart';
import 'trufi_locale_config.dart';
import 'social_media_config.dart';

/// Steps during app initialization.
enum AppInitStep {
  /// Initial state, starting up
  starting,

  /// Initializing overlay managers
  initializingOverlays,

  /// Loading map engines
  loadingMaps,

  /// Loading routing engines
  loadingRoutes,

  /// Preparing screen modules
  preparingScreens,
}

/// Builder for custom app initialization screen.
///
/// Parameters:
/// - [currentStep]: Current initialization step (null if error)
/// - [errorMessage]: Error message if initialization failed (null if loading)
/// - [onRetry]: Callback to retry initialization after an error
///
/// Example:
/// ```dart
/// Widget myInitScreen(
///   BuildContext context,
///   AppInitStep? currentStep,
///   String? errorMessage,
///   VoidCallback onRetry,
/// ) {
///   if (errorMessage != null) {
///     return Column(
///       mainAxisAlignment: MainAxisAlignment.center,
///       children: [
///         Icon(Icons.error, color: Colors.red),
///         Text('Error: $errorMessage'),
///         ElevatedButton(onPressed: onRetry, child: Text('Retry')),
///       ],
///     );
///   }
///
///   return Column(
///     mainAxisAlignment: MainAxisAlignment.center,
///     children: [
///       CircularProgressIndicator(),
///       Text(_stepToString(currentStep)),
///     ],
///   );
/// }
/// ```
typedef AppInitScreenBuilder = Widget Function(
  BuildContext context,
  AppInitStep? currentStep,
  String? errorMessage,
  VoidCallback onRetry,
);

/// Application configuration
class AppConfiguration {
  final String appName;
  final List<TrufiScreen> screens;
  final TrufiLocaleConfig localeConfig;
  final TrufiThemeConfig themeConfig;
  final List<SocialMediaLink> socialMediaLinks;

  /// Optional default locale override.
  /// If provided, this will be used instead of [localeConfig.defaultLocale].
  final Locale? defaultLocale;

  /// Deep link scheme for route sharing (e.g., 'trufiapp').
  /// When set, shared routes will include a deep link URL that opens the app.
  final String? deepLinkScheme;

  /// Global providers that will be available to all screens.
  ///
  /// Use this to inject shared state managers:
  /// - MapEngineManager (required)
  /// - RoutingEngineManager (required)
  /// - OverlayManager (required)
  /// - SearchLocationsCubit, POILayersCubit, etc.
  ///
  /// Example:
  /// ```dart
  /// providers: [
  ///   ChangeNotifierProvider(
  ///     create: (_) => MapEngineManager(engines: [...]),
  ///   ),
  ///   ChangeNotifierProvider(
  ///     create: (_) => RoutingEngineManager(engines: [...]),
  ///   ),
  ///   ChangeNotifierProvider(
  ///     create: (_) => OverlayManager(managers: [...]),
  ///   ),
  /// ]
  /// ```
  final List<SingleChildWidget> providers;

  /// Optional custom initialization screen builder.
  ///
  /// If provided, this will be used instead of the default initialization UI.
  /// The builder receives:
  /// - [currentStep]: Current step (null if error occurred)
  /// - [errorMessage]: Error message (null if loading normally)
  /// - [onRetry]: Callback to retry initialization
  ///
  /// If null, a beautiful default initialization screen is shown.
  final AppInitScreenBuilder? initScreenBuilder;

  const AppConfiguration({
    required this.appName,
    required this.screens,
    this.localeConfig = const TrufiLocaleConfig(),
    this.themeConfig = const TrufiThemeConfig(),
    this.socialMediaLinks = const [],
    this.deepLinkScheme,
    this.defaultLocale,
    this.providers = const [],
    this.initScreenBuilder,
  });
}
