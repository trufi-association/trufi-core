import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

import 'screen_menu_item.dart';
import 'screen_theme_data.dart';

export 'screen_menu_item.dart';
export 'screen_theme_data.dart';

/// Represents a sub-route within a TrufiScreen
class TrufiSubRoute {
  /// The path segment for this sub-route (e.g., 'detail')
  /// Will be appended to parent screen's path
  final String path;

  /// Widget builder that receives context and query parameters
  final Widget Function(BuildContext context, Map<String, String> queryParams) builder;

  /// Whether this sub-route provides its own AppBar
  final bool hasOwnAppBar;

  const TrufiSubRoute({
    required this.path,
    required this.builder,
    this.hasOwnAppBar = true,
  });
}

/// Abstract class for all Trufi screen modules
///
/// Screens can optionally implement asynchronous initialization by overriding
/// the [initialize] method. This method is called automatically by [runTrufiApp]
/// during app startup, with a loading screen shown to the user.
abstract class TrufiScreen {
  /// Unique identifier for this screen (used for routing name)
  String get id;

  /// The route path for this screen (e.g., '/', '/search', '/settings')
  String get path;

  /// Widget builder for this screen
  Widget Function(BuildContext context) get builder;

  /// Dependencies on other screens (by id)
  List<String> get dependencies => [];

  /// Localization delegates for this screen
  List<LocalizationsDelegate> get localizationsDelegates;

  /// Supported locales for this screen
  List<Locale> get supportedLocales => [];

  /// Menu item configuration (null if not shown in menu)
  ScreenMenuItem? get menuItem => null;

  /// Theme data for this screen
  ScreenThemeData? get themeData => null;

  /// Providers for this screen
  List<SingleChildWidget> get providers => [];

  /// Whether this screen provides its own AppBar (default: false)
  /// Set to true if the screen needs a custom AppBar instead of the shared one
  bool get hasOwnAppBar => false;

  /// Sub-routes for this screen (nested routes under this screen's path)
  /// Each entry is a map with 'path' and 'builder' keys.
  /// Example: [{'path': 'detail', 'builder': (context, params) => DetailScreen(...)}]
  List<TrufiSubRoute> get subRoutes => [];

  /// Initialize the screen module.
  ///
  /// This method is called automatically by [runTrufiApp] during app startup.
  /// Override this to perform async initialization like loading from storage.
  Future<void> initialize() async {}

  Future<void> dispose() async {}

  /// Get localized title for this screen (override for translations)
  String getLocalizedTitle(BuildContext context);
}
