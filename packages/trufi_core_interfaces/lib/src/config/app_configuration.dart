import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'app_overlay_manager.dart';
import 'trufi_screen.dart';
import 'trufi_theme_config.dart';
import 'trufi_locale_config.dart';
import 'social_media_config.dart';

/// Builder for the loading screen shown during app initialization.
///
/// Parameters:
/// - [context]: The build context
///
/// Example:
/// ```dart
/// Widget myLoadingScreen(BuildContext context) {
///   return Scaffold(
///     body: Center(
///       child: Column(
///         mainAxisAlignment: MainAxisAlignment.center,
///         children: [
///           CircularProgressIndicator(),
///           SizedBox(height: 16),
///           Text('Loading...'),
///         ],
///       ),
///     ),
///   );
/// }
/// ```
typedef LoadingScreenBuilder = Widget Function(BuildContext context);

/// Builder for the error screen shown when initialization fails.
///
/// Parameters:
/// - [context]: The build context
/// - [error]: The error that occurred
/// - [onRetry]: Callback to retry initialization
///
/// Example:
/// ```dart
/// Widget myErrorScreen(
///   BuildContext context,
///   Object error,
///   VoidCallback onRetry,
/// ) {
///   return Scaffold(
///     body: Center(
///       child: Column(
///         mainAxisAlignment: MainAxisAlignment.center,
///         children: [
///           Icon(Icons.error, size: 64, color: Colors.red),
///           SizedBox(height: 16),
///           Text('Error: $error'),
///           SizedBox(height: 16),
///           ElevatedButton(
///             onPressed: onRetry,
///             child: Text('Retry'),
///           ),
///         ],
///       ),
///     ),
///   );
/// }
/// ```
typedef ErrorScreenBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback onRetry,
);

/// Factory function for creating custom app initializer widgets.
///
/// This builder allows you to completely customize the initialization flow.
/// The [TrufiApp] will call the async initialization internally and manage the state.
///
/// Parameters:
/// - [context]: The build context
/// - [initializeAsync]: Async callback that performs the initialization (call this to start)
/// - [child]: The main app widget to show after initialization completes
///
/// Example:
/// ```dart
/// Widget myCustomInitializer(
///   BuildContext context,
///   Future<void> Function() initializeAsync,
///   Widget child,
/// ) {
///   return MyCustomInitializerWidget(
///     onInit: initializeAsync,
///     child: child,
///   );
/// }
/// ```
typedef AppInitializerBuilder = Widget Function(
  BuildContext context,
  Future<void> Function() initializeAsync,
  Widget child,
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
  /// Use this to inject shared state like MapEngineManager, SavedPlacesCubit, etc.
  ///
  /// Example:
  /// ```dart
  /// providers: [
  ///   BlocProvider(
  ///     create: (_) => POILayersCubit(...),
  ///   ),
  ///   ChangeNotifierProvider(
  ///     create: (_) => MapEngineManager(...),
  ///   ),
  /// ]
  /// ```
  final List<SingleChildWidget> providers;

  /// App-level appOverlayManagers that need async initialization.
  ///
  /// These appOverlayManagers will be:
  /// 1. Automatically injected as ChangeNotifierProviders
  /// 2. Initialized during the app initialization phase (before screens)
  /// 3. Available throughout the app via Provider
  ///
  /// Example:
  /// ```dart
  /// appOverlayManagers: [
  ///   OnboardingManager(),
  ///   PrivacyConsentManager(),
  ///   MyCustomManager(),
  /// ]
  /// ```
  final List<AppOverlayManager> appOverlayManagers;


  /// Optional custom loading screen builder.
  ///
  /// If provided, this will be used instead of the default loading spinner
  /// during app initialization.
  ///
  /// If null, the default loading screen with spinner is used.
  final LoadingScreenBuilder? loadingScreenBuilder;

  /// Optional custom error screen builder.
  ///
  /// If provided, this will be used instead of the default error screen
  /// when initialization fails.
  ///
  /// If null, the default error screen with retry button is used.
  final ErrorScreenBuilder? errorScreenBuilder;

  /// Optional custom app initializer builder.
  ///
  /// If provided, this will be used instead of the default initialization flow.
  /// This gives you complete control over the initialization UI and flow.
  ///
  /// If null, the default initialization flow with [loadingScreenBuilder] and
  /// [errorScreenBuilder] is used.
  final AppInitializerBuilder? appInitializerBuilder;

  const AppConfiguration({
    required this.appName,
    required this.screens,
    this.localeConfig = const TrufiLocaleConfig(),
    this.themeConfig = const TrufiThemeConfig(),
    this.socialMediaLinks = const [],
    this.deepLinkScheme,
    this.defaultLocale,
    this.providers = const [],
    this.appOverlayManagers = const [],
    this.loadingScreenBuilder,
    this.errorScreenBuilder,
    this.appInitializerBuilder,
  });
}
