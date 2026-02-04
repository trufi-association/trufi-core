import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/poi_category_config.dart';
import '../l10n/poi_layers_localizations.dart';
import '../poi_layers_manager.dart';

/// Helper to get localizations
POILayersLocalizations _getL10n(BuildContext context) {
  return POILayersLocalizations.of(context);
}

/// A settings section widget for configuring POI layer visibility.
/// Can be integrated into a settings screen or shown as a standalone modal.
class POILayersSettingsSection extends StatelessWidget {


  /// Optional section title
  final String? title;

  const POILayersSettingsSection({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = _getL10n(context);
    final manager = context.watch<POILayersManager>();
    final categories = manager.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        _POILayersHeader(title: title ?? l10n.pointsOfInterest),
        const SizedBox(height: 8),
        // Category toggles - dynamically loaded from metadata
        ...categories.map((category) {
          final availableSubcats = manager.availableSubcategories[category.name];
          final enabledSubcats = manager.enabledSubcategories[category.name];
          // Category is enabled if it has any enabled subcategories
          final isEnabled = enabledSubcats != null && enabledSubcats.isNotEmpty;

          return _POICategoryTile(
            category: category,
            isEnabled: isEnabled,
            availableSubcategories: availableSubcats,
            enabledSubcategories: enabledSubcats,
            onSubcategoryToggled: (subcategory, enabled) =>
                manager.toggleSubcategory(category.name, subcategory, enabled),
            onToggleAll: (enableAll) =>
                manager.toggleCategory(category.name, enableAll),
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
    final l10n = _getL10n(context);

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

/// Individual POI category tile with expandable subcategories
class _POICategoryTile extends StatefulWidget {
  final POICategoryConfig category;
  final bool isEnabled;
  final Set<String>? availableSubcategories;
  final Set<String>? enabledSubcategories;
  final void Function(String subcategory, bool enabled)? onSubcategoryToggled;
  final void Function(bool enableAll)? onToggleAll;

  const _POICategoryTile({
    required this.category,
    required this.isEnabled,
    this.availableSubcategories,
    this.enabledSubcategories,
    this.onSubcategoryToggled,
    this.onToggleAll,
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
    final l10n = _getL10n(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isEnabled
              ? widget.category.color.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Main category tile - tapping expands/collapses subcategories
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasSubcategories
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => _isExpanded = !_isExpanded);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Category icon
                      _buildCategoryIcon(),
                      const SizedBox(width: 12),
                      // Category name and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.getLocalizedDisplayName(
                                Localizations.localeOf(context).languageCode,
                              ),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (hasSubcategories) ...[
                              const SizedBox(height: 1),
                              Text(
                                _getSubcategoryCountText(l10n),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Expand/collapse arrow for subcategories
                      if (hasSubcategories) ...[
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Subcategories (expandable with animation)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: hasSubcategories && _isExpanded
                  ? _SubcategoriesList(
                      category: widget.category,
                      subcategories: widget.availableSubcategories!.toList()
                        ..sort(),
                      enabledSubcategories: widget.enabledSubcategories ?? {},
                      onSubcategoryToggled: widget.onSubcategoryToggled!,
                      onToggleAll: widget.onToggleAll!,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final colorScheme = Theme.of(context).colorScheme;

    // Try to use SVG icon from metadata
    if (widget.category.iconSvg != null && widget.category.iconSvg!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.isEnabled
              ? widget.category.color.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.string(
          widget.category.iconSvg!,
          width: 28,
          height: 28,
        ),
      );
    }

    // Fallback to Material icon
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.isEnabled
            ? widget.category.color.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        widget.category.fallbackIcon,
        size: 20,
        color: widget.isEnabled
            ? widget.category.color
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getSubcategoryCountText(POILayersLocalizations l10n) {
    final total = widget.availableSubcategories?.length ?? 0;
    final enabled = widget.enabledSubcategories?.length ?? 0;
    if (enabled == 0) {
      return l10n.typesAvailable(total);
    }
    return l10n.typesActive(enabled, total);
  }
}

/// Widget to display subcategories list
class _SubcategoriesList extends StatelessWidget {
  final POICategoryConfig category;
  final List<String> subcategories;
  final Set<String> enabledSubcategories;
  final void Function(String subcategory, bool enabled) onSubcategoryToggled;
  final void Function(bool enableAll) onToggleAll;

  const _SubcategoriesList({
    required this.category,
    required this.subcategories,
    required this.enabledSubcategories,
    required this.onSubcategoryToggled,
    required this.onToggleAll,
  });

  /// Get display name for subcategory from metadata or format from string
  String _getSubcategoryDisplayName(
      String subcategoryName, String languageCode) {
    // Try to get from category metadata
    final subConfig = category.getSubcategory(subcategoryName);
    if (subConfig != null) {
      return subConfig.getLocalizedDisplayName(languageCode);
    }
    // Fallback: convert snake_case to Title Case
    return subcategoryName
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = _getL10n(context);

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
                Icon(Icons.tune_rounded, size: 16, color: category.color),
                const SizedBox(width: 8),
                Text(
                  l10n.subcategoryTypes,
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
                    final allEnabled =
                        enabledSubcategories.length == subcategories.length;
                    onToggleAll(!allEnabled);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    enabledSubcategories.length == subcategories.length
                        ? l10n.clearAll
                        : l10n.selectAll,
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
            final isEnabled = enabledSubcategories.contains(subcategory);
            final subConfig = category.getSubcategory(subcategory);
            final subcategoryColor = subConfig?.color ?? category.color;
            final langCode = Localizations.localeOf(context).languageCode;

            return _SubcategorySwitchTile(
              color: subcategoryColor,
              subcategory: subcategory,
              displayName: _getSubcategoryDisplayName(subcategory, langCode),
              iconSvg: subConfig?.iconSvg,
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
  final Color color;
  final String subcategory;
  final String displayName;
  final String? iconSvg;
  final bool isEnabled;
  final void Function(bool enabled) onToggle;

  const _SubcategorySwitchTile({
    required this.color,
    required this.subcategory,
    required this.displayName,
    this.iconSvg,
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
              // Icon or dot indicator
              if (iconSvg != null && iconSvg!.isNotEmpty)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.string(
                    iconSvg!,
                    width: 20,
                    height: 20,
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isEnabled ? color : colorScheme.outlineVariant,
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
                      ? color.withValues(alpha: 0.8)
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
