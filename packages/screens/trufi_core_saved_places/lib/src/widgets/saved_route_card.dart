import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/saved_places_localizations.dart';
import '../models/saved_route.dart';

/// Card for one saved route (#1005): title, origin/destination chips, one
/// badge per transit leg of the saved itinerary and a "distance, ~duration"
/// caption. Pure UI: every action is a typed callback the screen wires; a
/// null callback hides its menu entry, and the menu itself when all are null.
class SavedRouteCard extends StatelessWidget {
  const SavedRouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.onRename,
    this.onSwap,
    this.onDelete,
  });

  final SavedRoute route;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onSwap;
  final VoidCallback? onDelete;

  /// Six hex digits, the GTFS `route_color` shape.
  static final RegExp _sixHexDigits = RegExp(r'^[0-9a-fA-F]{6}$');

  /// Badge colour from a GTFS route colour (leading `#` tolerated); null or
  /// malformed values fall back to [fallback] instead of painting garbage.
  static Color badgeColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    final digits = hex.startsWith('#') ? hex.substring(1) : hex;
    if (!_sixHexDigits.hasMatch(digits)) return fallback;
    final parsed = int.tryParse('FF$digits', radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }

  bool get _hasMenu => onRename != null || onSwap != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = SavedPlacesLocalizations.of(context);
    final snapshot = route.snapshot;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(_Dimensions.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Dimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(_Dimensions.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: _Dimensions.iconBox,
                    height: _Dimensions.iconBox,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        _Dimensions.iconRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.route_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      route.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_hasMenu)
                    _RouteMenuButton(
                      onRename: onRename,
                      onSwap: onSwap,
                      onDelete: onDelete,
                      localization: localization,
                    ),
                ],
              ),
              const SizedBox(height: _Dimensions.gap),
              Row(
                children: [
                  Flexible(
                    child: _EndpointChip(
                      icon: Icons.trip_origin_rounded,
                      label: localization.routeOrigin(route.origin.name),
                    ),
                  ),
                  const SizedBox(width: _Dimensions.gap),
                  Flexible(
                    child: _EndpointChip(
                      icon: Icons.place_rounded,
                      label: localization.routeDestination(
                        route.destination.name,
                      ),
                    ),
                  ),
                ],
              ),
              if (snapshot != null) ...[
                const SizedBox(height: _Dimensions.gap),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (snapshot.transitLegs.isEmpty)
                            const _WalkBadge()
                          else
                            for (final leg in snapshot.transitLegs)
                              _TransitBadge(leg: leg),
                        ],
                      ),
                    ),
                    const SizedBox(width: _Dimensions.gap),
                    Text(
                      localization.routeSummary(
                        _formatDistance(snapshot.distanceMeters, localization),
                        _formatDuration(
                          Duration(seconds: snapshot.durationSeconds),
                          localization,
                        ),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Same rules as the itinerary card in the home screen.
String _formatDistance(int meters, SavedPlacesLocalizations l10n) {
  if (meters < 1000) return l10n.distanceMeters(meters);
  return l10n.distanceKilometers((meters / 1000).toStringAsFixed(1));
}

String _formatDuration(Duration duration, SavedPlacesLocalizations l10n) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
  return l10n.durationMinutes(minutes);
}

/// Card metrics. Outer shape (16 / 14) matches `SavedPlaceTile` so both
/// lists read as one family.
abstract final class _Dimensions {
  static const double radius = 16;
  static const double padding = 14;
  static const double iconBox = 44;
  static const double iconRadius = 12;
  static const double chipRadius = 8;
  static const double badgeRadius = 6;
  static const double gap = 8;
}

/// Outlined "Origin: …" / "Destination: …" chip.
class _EndpointChip extends StatelessWidget {
  const _EndpointChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(_Dimensions.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Route short name on the route colour; text colour picked for contrast.
class _TransitBadge extends StatelessWidget {
  const _TransitBadge({required this.leg});

  final SavedRouteTransitLeg leg;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = SavedRouteCard.badgeColor(
      leg.colorHex,
      colorScheme.primary,
    );
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_Dimensions.badgeRadius),
      ),
      child: Text(
        leg.shortName,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Neutral badge for a walk-only itinerary (no transit leg to show).
class _WalkBadge extends StatelessWidget {
  const _WalkBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_Dimensions.badgeRadius),
      ),
      child: Icon(
        Icons.directions_walk_rounded,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _RouteAction { rename, swap, delete }

/// More-options popup menu (same look as the saved place tile's).
class _RouteMenuButton extends StatelessWidget {
  const _RouteMenuButton({
    this.onRename,
    this.onSwap,
    this.onDelete,
    required this.localization,
  });

  final VoidCallback? onRename;
  final VoidCallback? onSwap;
  final VoidCallback? onDelete;
  final SavedPlacesLocalizations localization;

  static const Map<_RouteAction, IconData> _icons = {
    _RouteAction.rename: Icons.edit_rounded,
    _RouteAction.swap: Icons.swap_vert_rounded,
    _RouteAction.delete: Icons.delete_rounded,
  };

  static final Map<_RouteAction, String Function(SavedPlacesLocalizations)>
  _labels = {
    _RouteAction.rename: (l10n) => l10n.renameRoute,
    _RouteAction.swap: (l10n) => l10n.swapDirection,
    _RouteAction.delete: (l10n) => l10n.removeRoute,
  };

  Map<_RouteAction, VoidCallback?> get _handlers => {
    _RouteAction.rename: onRename,
    _RouteAction.swap: onSwap,
    _RouteAction.delete: onDelete,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final handlers = _handlers;
    final actions = _RouteAction.values
        .where((action) => handlers[action] != null)
        .toList();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: PopupMenuButton<_RouteAction>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 22,
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        onSelected: (action) {
          HapticFeedback.lightImpact();
          handlers[action]?.call();
        },
        itemBuilder: (context) => [
          for (final action in actions) ...[
            // Delete sits apart from the editing actions.
            if (action == _RouteAction.delete && actions.length > 1)
              const PopupMenuDivider(height: 8),
            PopupMenuItem<_RouteAction>(
              value: action,
              child: _MenuRow(
                icon: _icons[action]!,
                label: _labels[action]!(localization),
                destructive: action == _RouteAction.delete,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.destructive,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = destructive ? colorScheme.error : colorScheme.primary;
    final container = destructive
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: container.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: destructive ? colorScheme.error : null,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
