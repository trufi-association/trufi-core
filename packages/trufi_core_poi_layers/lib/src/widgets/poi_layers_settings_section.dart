import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/poi_category.dart';
import '../l10n/poi_layers_localizations.dart';
import '../l10n/poi_layers_localizations_ext.dart';

/// A settings section widget for configuring POI layer visibility.
/// Can be integrated into a settings screen or shown as a standalone modal.
class POILayersSettingsSection extends StatelessWidget {
  /// Enabled subcategories per category
  final Map<POICategory, Set<String>> enabledSubcategories;

  /// Available subcategories per category
  final Map<POICategory, Set<String>> availableSubcategories;

  /// Callback when a category is toggled (enables/disables all its subcategories)
  final void Function(POICategory category, bool enabled) onCategoryToggled;

  /// Callback when a subcategory is toggled
  final void Function(POICategory category, String subcategory, bool enabled) onSubcategoryToggled;

  /// Optional section title
  final String? title;

  const POILayersSettingsSection({
    super.key,
    required this.enabledSubcategories,
    required this.availableSubcategories,
    required this.onCategoryToggled,
    required this.onSubcategoryToggled,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = POILayersLocalizations.of(context)!;

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
          final availableSubcats = availableSubcategories[category];
          final enabledSubcats = enabledSubcategories[category];
          // Category is enabled if it has any enabled subcategories
          final isEnabled = enabledSubcats != null && enabledSubcats.isNotEmpty;

          return _POICategoryTile(
            category: category,
            isEnabled: isEnabled,
            onToggle: (enabled) => onCategoryToggled(category, enabled),
            availableSubcategories: availableSubcats,
            enabledSubcategories: enabledSubcats,
            onSubcategoryToggled: (subcategory, enabled) =>
                onSubcategoryToggled(category, subcategory, enabled),
          );
        }),
      ],
    );
  }

}

/// Simple text header for POI layers section
class _POILayersHeader extends StatelessWidget {
  final String title;

  const _POILayersHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = POILayersLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.toggleLayersOnTheMap,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual POI category toggle tile with subcategory support
class _POICategoryTile extends StatefulWidget {
  final POICategory category;
  final bool isEnabled;
  final void Function(bool enabled) onToggle;
  final Set<String>? availableSubcategories;
  final Set<String>? enabledSubcategories;
  final void Function(String subcategory, bool enabled)? onSubcategoryToggled;

  const _POICategoryTile({
    required this.category,
    required this.isEnabled,
    required this.onToggle,
    this.availableSubcategories,
    this.enabledSubcategories,
    this.onSubcategoryToggled,
  });

  @override
  State<_POICategoryTile> createState() => _POICategoryTileState();
}

class _POICategoryTileState extends State<_POICategoryTile> {
  bool _isExpanded = false;

  bool get hasSubcategories =>
      widget.availableSubcategories != null &&
      widget.availableSubcategories!.isNotEmpty &&
      widget.onSubcategoryToggled != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = POILayersLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isEnabled
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Main category tile
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // If has subcategories, expand when enabling
                  if (hasSubcategories && !widget.isEnabled) {
                    setState(() => _isExpanded = true);
                  }
                  widget.onToggle(!widget.isEnabled);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.isEnabled
                              ? widget.category.color.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.category.icon,
                          size: 20,
                          color: widget.isEnabled
                              ? widget.category.color
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Category name and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.categoryName(widget.category.name),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (hasSubcategories) ...[
                              const SizedBox(height: 1),
                              Text(
                                _getSubcategoryCountText(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Expand/collapse button for subcategories
                      if (hasSubcategories && widget.isEnabled) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isExpanded = !_isExpanded);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.expand_more_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Switch toggle
                      Switch(
                        value: widget.isEnabled,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          if (hasSubcategories && value) {
                            setState(() => _isExpanded = true);
                          }
                          widget.onToggle(value);
                        },
                        activeTrackColor: widget.category.color,
                        activeThumbColor: colorScheme.surface,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Subcategories (expandable with animation)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: hasSubcategories && widget.isEnabled && _isExpanded
                  ? _SubcategoriesList(
                      category: widget.category,
                      subcategories: widget.availableSubcategories!.toList()..sort(),
                      enabledSubcategories: widget.enabledSubcategories ?? {},
                      onSubcategoryToggled: widget.onSubcategoryToggled!,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubcategoryCountText() {
    final total = widget.availableSubcategories?.length ?? 0;
    final enabled = widget.enabledSubcategories?.length ?? 0;
    if (enabled == 0) {
      return '$total tipos disponibles';
    }
    return '$enabled de $total tipos activos';
  }
}

/// Widget to display subcategories list
class _SubcategoriesList extends StatelessWidget {
  final POICategory category;
  final List<String> subcategories;
  final Set<String> enabledSubcategories;
  final void Function(String subcategory, bool enabled) onSubcategoryToggled;

  const _SubcategoriesList({
    required this.category,
    required this.subcategories,
    required this.enabledSubcategories,
    required this.onSubcategoryToggled,
  });

  String _formatSubcategoryName(String subcategory) {
    // Convert snake_case to Title Case
    return subcategory
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Select All" button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: category.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipos',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    // Toggle all subcategories
                    final allEnabled = enabledSubcategories.length == subcategories.length;
                    for (final subcat in subcategories) {
                      onSubcategoryToggled(subcat, !allEnabled);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    enabledSubcategories.length == subcategories.length ? 'Limpiar' : 'Todos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Subcategories switches
          ...subcategories.map((subcategory) {
            // If no subcategories are explicitly enabled, treat all as enabled
            final isEnabled = enabledSubcategories.isEmpty ||
                              enabledSubcategories.contains(subcategory);

            return _SubcategorySwitchTile(
              category: category,
              subcategory: subcategory,
              displayName: _formatSubcategoryName(subcategory),
              isEnabled: isEnabled,
              onToggle: (enabled) => onSubcategoryToggled(subcategory, enabled),
            );
          }),
        ],
      ),
    );
  }
}

/// Individual subcategory switch tile
class _SubcategorySwitchTile extends StatelessWidget {
  final POICategory category;
  final String subcategory;
  final String displayName;
  final bool isEnabled;
  final void Function(bool enabled) onToggle;

  const _SubcategorySwitchTile({
    required this.category,
    required this.subcategory,
    required this.displayName,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle(!isEnabled);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? category.color
                      : colorScheme.outlineVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Subcategory name
              Expanded(
                child: Text(
                  displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isEnabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              // Switch toggle (smaller version)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isEnabled
                      ? category.color.withValues(alpha: 0.8)
                      : colorScheme.outlineVariant,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: isEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

