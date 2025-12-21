import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/poi_category.dart';
import '../l10n/poi_layers_localizations.dart';

/// A settings section widget for configuring POI layer visibility.
/// Can be integrated into a settings screen or shown as a standalone modal.
class POILayersSettingsSection extends StatelessWidget {
  /// Current enabled state for each category
  final Map<POICategory, bool> enabledCategories;

  /// Callback when a category is toggled
  final void Function(POICategory category, bool enabled) onCategoryToggled;

  /// Optional section title
  final String? title;

  const POILayersSettingsSection({
    super.key,
    required this.enabledCategories,
    required this.onCategoryToggled,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = POILayersLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        _POILayersHeader(
          title: title ?? l10n.pointsOfInterest,
        ),
        const SizedBox(height: 8),
        // Category toggles
        ...POICategory.values.map((category) {
          final isEnabled = enabledCategories[category] ?? false;
          return _POICategoryTile(
            category: category,
            isEnabled: isEnabled,
            onToggle: (enabled) => onCategoryToggled(category, enabled),
          );
        }),
      ],
    );
  }

  /// Show as a bottom sheet modal
  static Future<void> showAsBottomSheet(
    BuildContext context, {
    required Map<POICategory, bool> enabledCategories,
    required void Function(POICategory category, bool enabled) onCategoryToggled,
    String? title,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _POILayersBottomSheet(
        enabledCategories: enabledCategories,
        onCategoryToggled: onCategoryToggled,
        title: title,
      ),
    );
  }
}

/// Header for the POI layers section
class _POILayersHeader extends StatelessWidget {
  final String title;

  const _POILayersHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = POILayersLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.secondaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.place_rounded,
              size: 26,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.toggleLayersOnTheMap,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual POI category toggle tile
class _POICategoryTile extends StatelessWidget {
  final POICategory category;
  final bool isEnabled;
  final void Function(bool enabled) onToggle;

  const _POICategoryTile({
    required this.category,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = POILayersLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isEnabled
            ? category.color.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(!isEnabled);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? category.color.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: isEnabled ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? category.color.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    size: 22,
                    color: isEnabled ? category.color : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                // Category name
                Expanded(
                  child: Text(
                    l10n.categoryName(category),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                      color: isEnabled ? category.color : colorScheme.onSurface,
                    ),
                  ),
                ),
                // Toggle switch
                Switch.adaptive(
                  value: isEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    onToggle(value);
                  },
                  activeTrackColor: category.color,
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for POI layers settings
class _POILayersBottomSheet extends StatefulWidget {
  final Map<POICategory, bool> enabledCategories;
  final void Function(POICategory category, bool enabled) onCategoryToggled;
  final String? title;

  const _POILayersBottomSheet({
    required this.enabledCategories,
    required this.onCategoryToggled,
    this.title,
  });

  @override
  State<_POILayersBottomSheet> createState() => _POILayersBottomSheetState();
}

class _POILayersBottomSheetState extends State<_POILayersBottomSheet> {
  late Map<POICategory, bool> _localEnabledCategories;

  @override
  void initState() {
    super.initState();
    _localEnabledCategories = Map.from(widget.enabledCategories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = POILayersLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title ?? l10n.pointsOfInterest,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable category list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: POICategory.values.length,
                itemBuilder: (context, index) {
                  final category = POICategory.values[index];
                  final isEnabled = _localEnabledCategories[category] ?? false;
                  return _POICategoryTile(
                    category: category,
                    isEnabled: isEnabled,
                    onToggle: (enabled) {
                      setState(() {
                        _localEnabledCategories[category] = enabled;
                      });
                      widget.onCategoryToggled(category, enabled);
                    },
                  );
                },
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(l10n.done),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
