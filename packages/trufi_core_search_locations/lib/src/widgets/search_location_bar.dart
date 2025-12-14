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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: isPortrait
                ? _buildPortraitLayout(context, theme)
                : _buildLandscapeLayout(context, theme),
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
              // Text fields
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Origin field
                    _LocationFieldCompact(
                      isOrigin: true,
                      hintText: configuration.originHintText,
                      value: state.origin,
                      onTap: () => _handleSearch(context, isOrigin: true),
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    // Destination field
                    _LocationFieldCompact(
                      isOrigin: false,
                      hintText: configuration.destinationHintText,
                      value: state.destination,
                      onTap: () => _handleSearch(context, isOrigin: false),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action buttons column (swap & reset)
        if (state.isComplete && (onSwap != null || onReset != null)) ...[
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onSwap != null)
                _ActionButton(
                  icon: Icons.swap_vert_rounded,
                  color: theme.colorScheme.primaryContainer,
                  iconColor: theme.colorScheme.onPrimaryContainer,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSwap!();
                  },
                ),
              if (onSwap != null && onReset != null)
                const SizedBox(height: 8),
              if (onReset != null)
                _ActionButton(
                  icon: Icons.close_rounded,
                  color: theme.colorScheme.errorContainer,
                  iconColor: theme.colorScheme.error,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onReset!();
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLocationDot({required bool isOrigin}) {
    final color = isOrigin ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Menu button
        if (showMenuButton && onMenuPressed != null) ...[
          _MenuButtonModern(onPressed: onMenuPressed!),
          const SizedBox(width: 8),
        ],

        // Origin field
        Expanded(
          child: _LocationFieldModern(
            isOrigin: true,
            hintText: configuration.originHintText,
            value: state.origin,
            onTap: () => _handleSearch(context, isOrigin: true),
            theme: theme,
            leadingWidget: configuration.originLeadingWidget,
          ),
        ),

        // Swap button
        if (state.isComplete && onSwap != null) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.swap_horiz_rounded,
            color: theme.colorScheme.primaryContainer,
            iconColor: theme.colorScheme.onPrimaryContainer,
            onPressed: () {
              HapticFeedback.lightImpact();
              onSwap!();
            },
          ),
          const SizedBox(width: 8),
        ] else
          const SizedBox(width: 12),

        // Destination field
        Expanded(
          child: _LocationFieldModern(
            isOrigin: false,
            hintText: configuration.destinationHintText,
            value: state.destination,
            onTap: () => _handleSearch(context, isOrigin: false),
            theme: theme,
            leadingWidget: configuration.destinationLeadingWidget,
          ),
        ),

        // Reset button
        if (state.isComplete && onReset != null) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.close_rounded,
            color: theme.colorScheme.errorContainer,
            iconColor: theme.colorScheme.error,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onReset!();
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

/// Compact location field without leading icon (used with external dots)
class _LocationFieldCompact extends StatelessWidget {
  final bool isOrigin;
  final String hintText;
  final dynamic value;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LocationFieldCompact({
    required this.isOrigin,
    required this.hintText,
    required this.value,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
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
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
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

/// Modern styled location input field (for landscape)
class _LocationFieldModern extends StatelessWidget {
  final bool isOrigin;
  final String hintText;
  final dynamic value;
  final VoidCallback onTap;
  final ThemeData theme;
  final Widget? leadingWidget;

  const _LocationFieldModern({
    required this.isOrigin,
    required this.hintText,
    required this.value,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isOrigin
            ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
            : const Color(0xFFE53935).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOrigin ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            shape: BoxShape.circle,
            border: Border.all(
              color: isOrigin
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                  : const Color(0xFFE53935).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
      ),
    );
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

