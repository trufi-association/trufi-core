import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

import 'screen_menu_item.dart';
import 'screen_theme_data.dart';

export 'screen_menu_item.dart';
export 'screen_theme_data.dart';

/// Abstract class for all Trufi screen modules
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

  Future<void> initialize() async {}
  Future<void> dispose() async {}

  /// Get localized title for this screen (override for translations)
  String getLocalizedTitle(BuildContext context);
}
