import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/poi_category.dart';
import 'poi_layers_settings_section.dart';

/// A button widget that opens POI layers settings when pressed.
/// Designed to match the style of MapTypeButton.
class POILayersButton extends StatelessWidget {
  /// Current enabled state for each category
  final Map<POICategory, bool> enabledCategories;

  /// Callback when a category is toggled
  final void Function(POICategory category, bool enabled) onCategoryToggled;

  /// Tooltip message for the button
  final String? tooltip;

  /// Icon to display on the button
  final IconData icon;

  /// Icon color
  final Color? iconColor;

  /// Background color of the button
  final Color? backgroundColor;

  /// Size of the icon
  final double iconSize;

  /// Border radius of the button
  final double borderRadius;

  /// Padding inside the button
  final EdgeInsetsGeometry padding;

  /// Title for the settings sheet
  final String? settingsTitle;

  const POILayersButton({
    super.key,
    required this.enabledCategories,
    required this.onCategoryToggled,
    this.tooltip,
    this.icon = Icons.place_rounded,
    this.iconColor,
    this.backgroundColor,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.settingsTitle,
  });

  /// Check if any category is enabled
  bool get hasEnabledCategories =>
      enabledCategories.values.any((enabled) => enabled);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Tooltip(
        message: tooltip ?? 'Points of Interest',
        child: Stack(
          children: [
            IconButton(
              iconSize: iconSize,
              icon: Icon(
                icon,
                color: hasEnabledCategories
                    ? effectiveIconColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(effectiveBackgroundColor),
                padding: WidgetStatePropertyAll(padding),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
              onPressed: () => _openPOISettings(context),
            ),
            // Active indicator dot
            if (hasEnabledCategories)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: effectiveBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openPOISettings(BuildContext context) {
    HapticFeedback.lightImpact();
    POILayersSettingsSection.showAsBottomSheet(
      context,
      enabledCategories: enabledCategories,
      onCategoryToggled: onCategoryToggled,
      title: settingsTitle,
    );
  }
}
