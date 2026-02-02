import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/search_location_bar_configuration.dart';
import '../models/search_location_state.dart';

/// A modern search location bar with origin and destination fields.
///
/// This widget features:
/// - Glass-morphism style card design
/// - Animated transitions between states
/// - Visual connection between origin and destination
/// - Responsive layout for portrait/landscape
/// - Haptic feedback on interactions
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

  /// Called when a single location should be cleared.
  final OnClearLocation? onClearLocation;

  /// Called when routing settings should be opened.
  final OnRoutingSettings? onRoutingSettings;

  /// Whether to show the menu button.
  final bool showMenuButton;

  /// Whether to show the shadow around the card.
  /// Set to false when the SearchBar is inside a panel/container that already has its own shadow.
  final bool showShadow;

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
    this.onClearLocation,
    this.onRoutingSettings,
    this.showMenuButton = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8),
            // Use width-based layout instead of orientation
            // This ensures proper layout in side panels and narrow containers
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use portrait (vertical) layout if width < 500px
                final useVerticalLayout = constraints.maxWidth < 500;
                return useVerticalLayout
                    ? _buildPortraitLayout(context, theme)
                    : _buildLandscapeLayout(context, theme);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Menu button
        if (showMenuButton && onMenuPressed != null) ...[
          _MenuButtonModern(onPressed: onMenuPressed!),
          const SizedBox(width: 8),
        ],

        // Location fields with visual connector
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Visual connector dots
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLocationDot(isOrigin: true),
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  _buildLocationDot(isOrigin: false),
                ],
              ),
              const SizedBox(width: 12),
              // Text fields with individual clear buttons
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Origin field with clear button
                    _LocationFieldWithClear(
                      isOrigin: true,
                      hintText: configuration.originHintText,
                      value: state.origin,
                      onTap: () => _handleSearch(context, isOrigin: true),
                      onClear: onClearLocation != null
                          ? () {
                              HapticFeedback.lightImpact();
                              onClearLocation!(isOrigin: true);
                            }
                          : null,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    // Destination field with clear button
                    _LocationFieldWithClear(
                      isOrigin: false,
                      hintText: configuration.destinationHintText,
                      value: state.destination,
                      onTap: () => _handleSearch(context, isOrigin: false),
                      onClear: onClearLocation != null
                          ? () {
                              HapticFeedback.lightImpact();
                              onClearLocation!(isOrigin: false);
                            }
                          : null,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action buttons column (swap & routing settings)
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSwap != null)
              _ActionButton(
                icon: Icons.swap_vert_rounded,
                color: state.isComplete
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                iconColor: state.isComplete
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                onPressed: state.isComplete
                    ? () {
                        HapticFeedback.lightImpact();
                        onSwap!();
                      }
                    : null,
              ),
            if (onSwap != null && onRoutingSettings != null)
              const SizedBox(height: 8),
            if (onRoutingSettings != null)
              _ActionButton(
                icon: Icons.tune_rounded,
                color: theme.colorScheme.secondaryContainer,
                iconColor: theme.colorScheme.onSecondaryContainer,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRoutingSettings!();
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationDot({required bool isOrigin}) {
    const originColor = Color(0xFF4CAF50);
    const destinationColor = Color(0xFFE53935);

    if (isOrigin) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: originColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: originColor.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } else {
      return const Icon(
        Icons.place_rounded,
        color: destinationColor,
        size: 16,
      );
    }
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Menu button
        if (showMenuButton && onMenuPressed != null) ...[
          _MenuButtonModern(onPressed: onMenuPressed!),
          const SizedBox(width: 8),
        ],

        // Origin field with clear button
        Expanded(
          child: _LocationFieldModernWithClear(
            isOrigin: true,
            hintText: configuration.originHintText,
            value: state.origin,
            onTap: () => _handleSearch(context, isOrigin: true),
            onClear: onClearLocation != null && state.origin != null
                ? () {
                    HapticFeedback.lightImpact();
                    onClearLocation!(isOrigin: true);
                  }
                : null,
            theme: theme,
            leadingWidget: configuration.originLeadingWidget,
          ),
        ),

        // Swap button (always visible when onSwap provided, but disabled when incomplete)
        if (onSwap != null) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.swap_horiz_rounded,
            color: state.isComplete
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            iconColor: state.isComplete
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            onPressed: state.isComplete
                ? () {
                    HapticFeedback.lightImpact();
                    onSwap!();
                  }
                : null,
          ),
          const SizedBox(width: 8),
        ] else
          const SizedBox(width: 12),

        // Destination field with clear button
        Expanded(
          child: _LocationFieldModernWithClear(
            isOrigin: false,
            hintText: configuration.destinationHintText,
            value: state.destination,
            onTap: () => _handleSearch(context, isOrigin: false),
            onClear: onClearLocation != null && state.destination != null
                ? () {
                    HapticFeedback.lightImpact();
                    onClearLocation!(isOrigin: false);
                  }
                : null,
            theme: theme,
            leadingWidget: configuration.destinationLeadingWidget,
          ),
        ),

        // Routing settings button
        if (onRoutingSettings != null) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.tune_rounded,
            color: theme.colorScheme.secondaryContainer,
            iconColor: theme.colorScheme.onSecondaryContainer,
            onPressed: () {
              HapticFeedback.lightImpact();
              onRoutingSettings!();
            },
          ),
        ],
      ],
    );
  }

  Future<void> _handleSearch(BuildContext context, {required bool isOrigin}) async {
    HapticFeedback.selectionClick();
    final location = await onSearch(isOrigin: isOrigin);
    if (location != null) {
      if (isOrigin) {
        onOriginSelected(location);
      } else {
        onDestinationSelected(location);
      }
    }
  }
}

/// Compact location field with optional clear button
class _LocationFieldWithClear extends StatelessWidget {
  final bool isOrigin;
  final String hintText;
  final dynamic value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final ThemeData theme;

  const _LocationFieldWithClear({
    required this.isOrigin,
    required this.hintText,
    required this.value,
    required this.onTap,
    this.onClear,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final displayText = value?.formattedDisplay ?? hintText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hasValue
                      ? theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        )
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              if (hasValue && onClear != null)
                _ClearButton(onPressed: onClear!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small clear button for location fields
class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClearButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ),
      ),
    );
  }
}

/// Action button (swap, reset, etc.)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Modern styled location input field with clear button (for landscape)
class _LocationFieldModernWithClear extends StatelessWidget {
  final bool isOrigin;
  final String hintText;
  final dynamic value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final ThemeData theme;
  final Widget? leadingWidget;

  const _LocationFieldModernWithClear({
    required this.isOrigin,
    required this.hintText,
    required this.value,
    required this.onTap,
    this.onClear,
    required this.theme,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final displayText = value?.formattedDisplay ?? hintText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          padding: EdgeInsets.only(
            left: 12,
            right: hasValue && onClear != null ? 4 : 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasValue
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Leading icon (origin/destination marker)
              _buildLeadingIcon(),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      isOrigin ? 'From' : 'To',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    // Value or hint
                    Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasValue
                          ? theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            )
                          : theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.2,
                            ),
                    ),
                  ],
                ),
              ),
              // Clear button
              if (hasValue && onClear != null)
                _ClearButton(onPressed: onClear!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (leadingWidget != null) {
      return SizedBox(width: 24, height: 24, child: leadingWidget);
    }

    const originColor = Color(0xFF4CAF50);
    const destinationColor = Color(0xFFE53935);

    if (isOrigin) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: originColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: originColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: originColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
        ),
      );
    } else {
      return const Icon(
        Icons.place_rounded,
        color: destinationColor,
        size: 24,
      );
    }
  }
}

/// Modern menu button
class _MenuButtonModern extends StatelessWidget {
  final VoidCallback onPressed;

  const _MenuButtonModern({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.menu_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }
}

