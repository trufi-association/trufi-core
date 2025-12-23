import 'package:flutter/material.dart';

import '../l10n/poi_layers_localizations.dart';
import '../l10n/poi_layers_localizations_ext.dart';
import '../models/poi.dart';

/// Bottom sheet for selecting from multiple nearby POIs.
///
/// Use this widget when multiple POI markers overlap and the user
/// needs to select one.
///
/// Example usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   builder: (context) => POISelectionSheet(
///     pois: overlappingPOIs,
///     onPOISelected: (poi) {
///       Navigator.pop(context);
///       // Handle selection
///     },
///   ),
/// );
/// ```
class POISelectionSheet extends StatelessWidget {
  /// List of POIs to choose from
  final List<POI> pois;

  /// Callback when a POI is selected
  final void Function(POI poi) onPOISelected;

  const POISelectionSheet({
    super.key,
    required this.pois,
    required this.onPOISelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = POILayersLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.selectPlace,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.placesCount(pois.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // POI list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pois.length,
                itemBuilder: (context, index) {
                  final poi = pois[index];
                  return _POISelectionTile(
                    poi: poi,
                    onTap: () => onPOISelected(poi),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual tile for POI selection
class _POISelectionTile extends StatelessWidget {
  final POI poi;
  final VoidCallback onTap;

  const _POISelectionTile({
    required this.poi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = POILayersLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: poi.category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                poi.type.icon,
                color: poi.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // POI info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n.categoryName(poi.category.name),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
