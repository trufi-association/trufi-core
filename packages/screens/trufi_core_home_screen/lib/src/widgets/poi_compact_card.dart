import 'package:flutter/material.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/home_screen_localizations.dart';

/// Compact POI card shown at the bottom of the side panel in the wide layout
/// (>= 600 dp: tablets, phones in landscape, desktop web). The narrow layout
/// shows [POIDetailPanel] from `trufi_core_poi_layers` instead.
///
/// Kept as a public, self-contained widget so it can be widget-tested
/// without pumping the whole home screen (which needs a map engine).
///
/// Copying (trufi-sanaa#9) is at parity with [POIDetailPanel]: a copy button
/// next to the close button, plus long-press on the name and on the address.
class POICompactCard extends StatelessWidget {
  final POI poi;
  final VoidCallback onClose;
  final VoidCallback onSetAsOrigin;
  final VoidCallback onSetAsDestination;

  const POICompactCard({
    super.key,
    required this.poi,
    required this.onClose,
    required this.onSetAsOrigin,
    required this.onSetAsDestination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = HomeScreenLocalizations.of(context);
    // Shared by the copy and the close button so they stay aligned.
    const iconButtonConstraints = BoxConstraints(minWidth: 32, minHeight: 32);

    void copy(String text) =>
        copyToClipboard(context, text, confirmation: l10n.copiedToClipboard);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: poi.category.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    poi.category.fallbackIcon,
                    color: poi.category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () => copy(poi.displayName),
                        child: Text(
                          poi.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        poi.subcategoryConfig?.displayName ??
                            poi.subcategory ??
                            poi.category.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Visible copy button, as on the narrow panel: this is the
                // one layout with a mouse, where press-and-hold is the least
                // natural. Flutter ships the tooltip in every language.
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                  onPressed: () => copy(poi.displayName),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: iconButtonConstraints,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: iconButtonConstraints,
                ),
              ],
            ),
          ),
          // Details
          if (poi.address != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => copy(poi.address!),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        poi.address!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetAsOrigin,
                    icon: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    label: Text(l10n.setAsOrigin),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSetAsDestination,
                    icon: const Icon(Icons.place, size: 16),
                    label: Text(l10n.setAsDestination),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
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
