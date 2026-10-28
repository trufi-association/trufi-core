import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/transport_list_localizations.dart';
import '../nearby_lines_cubit.dart';
import '../nearby_street_anchor.dart';

/// Floating header of the nearby-lines screen, in the shape of the route
/// detail's top bar: a 44 px menu button, the title card (screen title over
/// the anchor line, plus the pin hint when the device position is not in
/// use) and 44 px buttons for "use my location" and close.
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

  /// Translucent, rounded and shadowed pieces when floating over the map
  /// (phone); flat on `surface` when the row heads the side panel (wide).
  final bool elevated;

  /// Title card height: `titleMedium` (24) + 2 + `bodySmall` anchor line
  /// (16) + 2 × 8 padding; the pin hint adds 2 + up to two `bodySmall`
  /// lines. The screen reserves this much map for the camera fit.
  static const double cardHeight = 58;
  static const double cardHeightWithHint = 92;

  /// The pin hint shows whenever the search is not anchored to a GPS fix.
  static bool showsHint(NearbyLinesState state) =>
      state.locationDenied || state.anchorSource == NearbyAnchorSource.fallback;

  static double heightFor(NearbyLinesState state) =>
      showsHint(state) ? cardHeightWithHint : cardHeight;

  static const Map<NearbyAnchorSource, IconData> _anchorIcons = {
    NearbyAnchorSource.device: Icons.my_location_rounded,
    NearbyAnchorSource.pin: Icons.push_pin_rounded,
    NearbyAnchorSource.fallback: Icons.location_searching_rounded,
    NearbyAnchorSource.street: Icons.signpost_rounded,
  };

  static final Map<
    NearbyAnchorSource,
    String Function(TransportListLocalizations, NearbyLinesState)
  >
  _anchorLabels = {
    NearbyAnchorSource.device: (l10n, _) => l10n.nearbyAnchorYourLocation,
    NearbyAnchorSource.pin: (l10n, _) => l10n.nearbyAnchorPinned,
    NearbyAnchorSource.fallback: (l10n, _) => l10n.nearbyAnchorDefault,
    NearbyAnchorSource.street: (l10n, state) =>
        _streetLabel(l10n, state.street),
  };

  /// "Along `<street>` · `<municipality>`": the subtitle tells same-named
  /// streets apart (Cochabamba's index has one "Avenida Circunvalación"
  /// per municipality); omitted when the index carries none.
  static String _streetLabel(
    TransportListLocalizations l10n,
    NearbyStreetAnchor? street,
  ) {
    final label = l10n.nearbyAnchorAlongStreet(street?.name ?? '');
    final subtitle = street?.subtitle;
    if (subtitle == null || subtitle.isEmpty) return label;
    return '$label · $subtitle';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    final showHint = showsHint(state);
    final anchorLabel = _anchorLabels[state.anchorSource]!(l10n, state);

    return Row(
      children: [
        _MapBarButton(
          icon: Icons.menu_rounded,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          elevated: elevated,
          onTap: onMenu,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: elevated
                ? colorScheme.surface.withValues(alpha: 0.95)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            elevation: elevated ? 2 : 0,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.menuNearbyLines,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        _anchorIcons[state.anchorSource],
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        // A long street name ellipsizes; the tooltip (long
                        // press) is the only place on this screen that
                        // shows it whole.
                        child: Tooltip(
                          message: anchorLabel,
                          child: Text(
                            anchorLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showHint) ...[
                    const SizedBox(height: 2),
                    Padding(
                      // Aligned with the anchor label (icon 14 + gap 6).
                      padding: const EdgeInsetsDirectional.only(start: 20),
                      child: Text(
                        l10n.nearbyMovePinHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _MapBarButton(
          icon: Icons.my_location_rounded,
          tooltip: l10n.nearbyUseMyLocation,
          elevated: elevated,
          onTap: state.isLocating
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onUseMyLocation();
                },
          child: state.isLocating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSurface,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        _MapBarButton(
          icon: Icons.close_rounded,
          tooltip: l10n.nearbyClose,
          elevated: elevated,
          onTap: onClose,
        ),
      ],
    );
  }
}

/// The 44 px square button of the map screens (the route detail's back and
/// share buttons): `surface` at 0.95 with a small shadow over the map,
/// `surfaceContainerHighest` and flat inside a side panel.
class _MapBarButton extends StatelessWidget {
  const _MapBarButton({
    required this.icon,
    required this.tooltip,
    required this.elevated,
    required this.onTap,
    this.child,
  });

  final IconData icon;
  final String tooltip;
  final bool elevated;
  final VoidCallback? onTap;

  /// Replaces the icon (a progress spinner while locating).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: elevated
          ? colorScheme.surface.withValues(alpha: 0.95)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      elevation: elevated ? 2 : 0,
      shadowColor: Colors.black26,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: child ?? Icon(icon, size: 22, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
