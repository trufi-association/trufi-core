import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/pages/home/widgets/location_search_bar/modals/full_screen_search_modal.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/base_marker/from_marker.dart';
import 'package:trufi_core/widgets/base_marker/to_marker.dart';

/// A widget that displays a route search interface with origin and destination inputs.
///
/// This component shows a compact search bar with two location fields (from/to),
/// markers, and action buttons for swapping locations and accessing menu options.
class RouteSearchComponent extends StatelessWidget {
  /// Callback invoked when an origin location is saved
  final void Function(TrufiLocation) onSaveFrom;

  /// Callback invoked when the origin location is cleared
  final void Function() onClearFrom;

  /// Callback invoked when a destination location is saved
  final void Function(TrufiLocation) onSaveTo;

  /// Callback invoked when the destination location is cleared
  final void Function() onClearTo;

  /// Callback invoked to fetch the route plan
  final void Function() onFetchPlan;

  /// Callback invoked to reset the route
  final void Function() onReset;

  /// Callback invoked to swap origin and destination
  final void Function() onSwap;

  /// The currently selected origin location
  final TrufiLocation? origin;

  /// The currently selected destination location
  final TrufiLocation? destination;

  const RouteSearchComponent({
    super.key,
    required this.onSaveFrom,
    required this.onClearFrom,
    required this.onSaveTo,
    required this.onClearTo,
    required this.onFetchPlan,
    required this.onReset,
    required this.onSwap,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withAlpha(120)
                  : Colors.black.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: isDark ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuButton(context, theme),
            _buildMarkerColumn(theme),
            Expanded(child: _buildLocationFields(context, theme)),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  /// Builds the menu button column
  Widget _buildMenuButton(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: IconButton(
            icon: const Icon(Icons.menu),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menu',
          ),
        ),
      ],
    );
  }

  /// Builds the column with from/to markers
  Widget _buildMarkerColumn(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const FromMarker(),
        _DotsWidget(color: theme.colorScheme.onSurfaceVariant),
        const ToMarker(),
      ],
    );
  }

  /// Builds the location input fields
  Widget _buildLocationFields(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Divider(
              height: 2,
              color: theme.colorScheme.outlineVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  _LocationField(
                    location: origin,
                    hintText: 'Choose start location',
                    onTap: () => _handleOriginSelection(context),
                  ),
                  _LocationField(
                    location: destination,
                    hintText: 'Choose destination location',
                    onTap: () => _handleDestinationSelection(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the action buttons (more options and swap)
  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: Implement more options menu
            },
            tooltip: 'More options',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: IconButton(
            icon: const Icon(Icons.swap_vert),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: onSwap,
            tooltip: 'Swap locations',
          ),
        ),
      ],
    );
  }

  /// Handles origin location selection
  Future<void> _handleOriginSelection(BuildContext context) async {
    final locationSelected = await FullScreenSearchModal.onLocationSelected(
      context,
      location: origin,
    );
    if (locationSelected != null) {
      onSaveFrom(locationSelected);
    }
  }

  /// Handles destination location selection
  Future<void> _handleDestinationSelection(BuildContext context) async {
    final locationSelected = await FullScreenSearchModal.onLocationSelected(
      context,
      location: destination,
    );
    if (locationSelected != null) {
      onSaveTo(locationSelected);
    }
  }
}

/// A widget that displays three vertical dots as a visual separator.
class _DotsWidget extends StatelessWidget {
  final Color color;

  const _DotsWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    final dot = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        width: 2.5,
        height: 2.5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );

    return SizedBox(
      width: 24,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [dot, dot, dot],
      ),
    );
  }
}

/// A widget that displays a location field with optional location data.
///
/// Shows either the location name or a hint text, along with an arrow indicator
/// when no location is selected.
class _LocationField extends StatelessWidget {
  final TrufiLocation? location;
  final String hintText;
  final VoidCallback onTap;

  const _LocationField({
    required this.location,
    required this.hintText,
    required this.onTap,
  });

  /// Checks if the current location is the user's current location
  bool get _isCurrentLocation => location?.description == 'Your Location';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _buildTextContent(context, theme),
        ),
      ),
    );
  }

  /// Builds the text content with appropriate styling
  Widget _buildTextContent(BuildContext context, ThemeData theme) {
    final displayText =
        location?.displayName(AppLocalization.of(context)) ?? hintText;

    final textColor = _getTextColor(theme);

    return Row(
      children: [
        Flexible(
          child: Text(
            displayText,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (location == null)
          Icon(
            Icons.keyboard_arrow_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }

  /// Determines the appropriate text color based on location state
  Color _getTextColor(ThemeData theme) {
    if (location != null) {
      return _isCurrentLocation
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface;
    }
    return theme.colorScheme.onSurfaceVariant;
  }
}
