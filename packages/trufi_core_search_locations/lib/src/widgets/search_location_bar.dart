import 'package:flutter/material.dart';

import '../models/search_location_bar_configuration.dart';
import '../models/search_location_state.dart';
import 'search_location_buttons.dart';
import 'search_location_field.dart';

/// A complete search location bar with origin and destination fields.
///
/// This widget adapts its layout based on screen orientation:
/// - Portrait: Fields stacked vertically
/// - Landscape: Fields arranged horizontally
///
/// The bar includes:
/// - Menu button (optional)
/// - Origin location field
/// - Destination location field
/// - Swap button (when both locations are set)
/// - Reset button (when both locations are set)
class SearchLocationBar extends StatelessWidget {
  /// The current state containing origin and destination.
  final SearchLocationState state;

  /// Configuration for appearance and text.
  final SearchLocationBarConfiguration configuration;

  /// Called when a location search is requested.
  final OnSearchLocation onSearch;

  /// Called when the origin location is selected.
  final OnLocationSelected onOriginSelected;

  /// Called when the destination location is selected.
  final OnLocationSelected onDestinationSelected;

  /// Called when locations should be swapped.
  final OnSwapLocations? onSwap;

  /// Called when the search should be reset.
  final OnResetSearch? onReset;

  /// Called when the menu button is pressed.
  final OnMenuPressed? onMenuPressed;

  /// Whether to show the menu button.
  final bool showMenuButton;

  const SearchLocationBar({
    super.key,
    required this.state,
    this.configuration = const SearchLocationBarConfiguration(),
    required this.onSearch,
    required this.onOriginSelected,
    required this.onDestinationSelected,
    this.onSwap,
    this.onReset,
    this.onMenuPressed,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: configuration.padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPortrait) const SizedBox(width: 30),
                  if (showMenuButton && onMenuPressed != null)
                    MenuButton(onPressed: onMenuPressed!),
                  Expanded(
                    child: isPortrait
                        ? _buildPortraitLayout(context)
                        : _buildLandscapeLayout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SearchLocationField(
            isOrigin: true,
            hintText: configuration.originHintText,
            leadingWidget: configuration.originLeadingWidget != null
                ? Container(
                    padding: const EdgeInsets.all(3.5),
                    child: configuration.originLeadingWidget,
                  )
                : null,
            trailingWidget:
                state.isComplete && onReset != null
                    ? ResetButton(onPressed: onReset!)
                    : null,
            value: state.origin,
            onSearch: onSearch,
            onLocationSelected: onOriginSelected,
            borderRadius: configuration.fieldBorderRadius,
            height: configuration.fieldHeight,
          ),
          SearchLocationField(
            isOrigin: false,
            hintText: configuration.destinationHintText,
            leadingWidget: configuration.destinationLeadingWidget,
            trailingWidget:
                state.isComplete && onSwap != null
                    ? SwapButton(
                        orientation: Orientation.portrait,
                        onPressed: onSwap!,
                      )
                    : null,
            value: state.destination,
            onSearch: onSearch,
            onLocationSelected: onDestinationSelected,
            borderRadius: configuration.fieldBorderRadius,
            height: configuration.fieldHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const SizedBox(width: 40.0),
            Flexible(
              child: SearchLocationField(
                isOrigin: true,
                hintText: configuration.originHintText,
                leadingWidget: configuration.originLeadingWidget != null
                    ? Container(
                        padding: const EdgeInsets.all(3.5),
                        child: configuration.originLeadingWidget,
                      )
                    : null,
                value: state.origin,
                onSearch: onSearch,
                onLocationSelected: onOriginSelected,
                borderRadius: configuration.fieldBorderRadius,
                height: configuration.fieldHeight,
              ),
            ),
            SizedBox(
              width: 40.0,
              child: state.isComplete && onSwap != null
                  ? SwapButton(
                      orientation: Orientation.landscape,
                      onPressed: onSwap!,
                    )
                  : null,
            ),
            Flexible(
              child: SearchLocationField(
                isOrigin: false,
                hintText: configuration.destinationHintText,
                leadingWidget: configuration.destinationLeadingWidget,
                value: state.destination,
                onSearch: onSearch,
                onLocationSelected: onDestinationSelected,
                borderRadius: configuration.fieldBorderRadius,
                height: configuration.fieldHeight,
              ),
            ),
            SizedBox(
              width: 40.0,
              child: state.isComplete && onReset != null
                  ? ResetButton(onPressed: onReset!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
