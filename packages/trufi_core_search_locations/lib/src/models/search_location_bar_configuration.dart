import 'package:flutter/material.dart';

import 'search_location.dart';

/// Configuration for the search location bar appearance and behavior.
class SearchLocationBarConfiguration {
  /// Hint text shown when origin field is empty.
  final String originHintText;

  /// Hint text shown when destination field is empty.
  final String destinationHintText;

  /// Widget shown as leading icon for the origin field.
  final Widget? originLeadingWidget;

  /// Widget shown as leading icon for the destination field.
  final Widget? destinationLeadingWidget;

  /// Border radius for the input fields.
  final BorderRadius fieldBorderRadius;

  /// Height of the input fields.
  final double fieldHeight;

  /// Padding around the bar content.
  final EdgeInsets padding;

  const SearchLocationBarConfiguration({
    this.originHintText = 'Select origin',
    this.destinationHintText = 'Select destination',
    this.originLeadingWidget,
    this.destinationLeadingWidget,
    this.fieldBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.fieldHeight = 36.0,
    this.padding = const EdgeInsets.all(5.0),
  });
}

/// Callback type for when a location search is requested.
///
/// [isOrigin] indicates whether this is for the origin (true) or destination (false).
/// Returns the selected [SearchLocation] or null if cancelled.
typedef OnSearchLocation = Future<SearchLocation?> Function({
  required bool isOrigin,
});

/// Callback type for when a location is selected/saved.
typedef OnLocationSelected = void Function(SearchLocation location);

/// Callback type for when locations should be swapped.
typedef OnSwapLocations = void Function();

/// Callback type for when the search should be reset.
typedef OnResetSearch = void Function();

/// Callback type for when a route search should be performed.
typedef OnSearchRoute = void Function();

/// Callback type for the menu button press.
typedef OnMenuPressed = void Function();

/// Callback type for clearing a single location (origin or destination).
typedef OnClearLocation = void Function({required bool isOrigin});

/// Callback type for opening routing settings.
typedef OnRoutingSettings = void Function();
