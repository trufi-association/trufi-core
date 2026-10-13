import 'package:flutter/material.dart';

import '../../../l10n/transport_list_localizations.dart';
import '../nearby_lines_cubit.dart';

/// Floating header of the nearby-lines screen: menu, title, close, and the
/// anchor row ("Your location" / "Pinned location" + "Use my location").
class NearbyHeaderCard extends StatelessWidget {
  const NearbyHeaderCard({
    super.key,
    required this.state,
    required this.onMenu,
    required this.onClose,
    required this.onUseMyLocation,
    this.elevated = true,
  });

  final NearbyLinesState state;
  final VoidCallback onMenu;
  final VoidCallback onClose;
  final VoidCallback onUseMyLocation;

  /// Rounded, translucent and shadowed when floating over the map (phone);
  /// flat when it heads the side panel (wide layouts).
  final bool elevated;

  static const Map<NearbyAnchorSource, IconData> _anchorIcons = {
    NearbyAnchorSource.device: Icons.my_location_rounded,
    NearbyAnchorSource.pin: Icons.push_pin_rounded,
    NearbyAnchorSource.fallback: Icons.location_searching_rounded,
  };

  static final Map<
    NearbyAnchorSource,
    String Function(TransportListLocalizations)
  >
  _anchorLabels = {
    NearbyAnchorSource.device: (l10n) => l10n.nearbyAnchorYourLocation,
    NearbyAnchorSource.pin: (l10n) => l10n.nearbyAnchorPinned,
    NearbyAnchorSource.fallback: (l10n) => l10n.nearbyAnchorDefault,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    final showHint =
        state.locationDenied ||
        state.anchorSource == NearbyAnchorSource.fallback;

    return Material(
      color: elevated
          ? colorScheme.surface.withValues(alpha: 0.95)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(elevated ? 16 : 0),
      elevation: elevated ? 2 : 0,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: onMenu,
              ),
              Expanded(
                child: Text(
                  l10n.menuNearbyLines,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.nearbyClose,
                onPressed: onClose,
              ),
            ],
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Icon(
                  _anchorIcons[state.anchorSource],
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _anchorLabels[state.anchorSource]!(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showHint)
                        Text(
                          l10n.nearbyMovePinHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: state.isLocating ? null : onUseMyLocation,
                  icon: state.isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(l10n.nearbyUseMyLocation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
