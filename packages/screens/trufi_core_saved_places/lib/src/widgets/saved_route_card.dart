import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show TransportModeExtension;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/saved_places_localizations.dart';
import '../models/saved_route.dart';

/// Card for one saved route (#1005), in the family of `SavedPlaceTile`:
/// tinted icon tile, title, the origin → destination terminals of the route
/// detail, one [RouteBadge] per transit leg of the saved itinerary and the
/// distance / duration chips of the itinerary card. Pure UI: every action is
/// a typed callback the screen wires; a null callback hides its menu entry,
/// and the menu itself when all are null.
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
        // Long-press copies the name, as the saved place tile does.
        onLongPress: () => copyToClipboard(
          context,
          route.name,
          confirmation: localization.copiedToClipboard,
        ),
        borderRadius: BorderRadius.circular(_Dimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(_Dimensions.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _Dimensions.iconBox,
                height: _Dimensions.iconBox,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(_Dimensions.iconRadius),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // As tall as the icon tile (the menu button's 48 px), so
                    // the title sits centred on the tile like the saved
                    // place tile's does, with or without a menu.
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _Dimensions.iconBox,
                      ),
                      child: Row(
                        children: [
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
                          if (_hasMenu) ...[
                            const SizedBox(width: 4),
                            _RouteMenuButton(
                              onRename: onRename,
                              onSwap: onSwap,
                              onDelete: onDelete,
                              localization: localization,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    _Terminals(
                      origin: route.origin.name,
                      destination: route.destination.name,
                      localization: localization,
                    ),
                    if (snapshot != null) ...[
                      const SizedBox(height: _Dimensions.gap),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (snapshot.transitLegs.isEmpty)
                            const _WalkBadge()
                          else
                            for (final leg in snapshot.transitLegs)
                              _legBadge(leg, colorScheme),
                          _InfoChip(
                            icon: Icons.straighten_rounded,
                            label: _formatDistance(
                              snapshot.distanceMeters,
                              localization,
                            ),
                          ),
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: _formatDuration(
                              Duration(seconds: snapshot.durationSeconds),
                              localization,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The itinerary card's leg chip: GTFS colours when the snapshot has them,
  /// the theme's primary otherwise; the mode glyph when the mode was saved,
  /// the badge's own bus for routes saved before it existed.
  Widget _legBadge(SavedRouteTransitLeg leg, ColorScheme colorScheme) {
    final mode = leg.mode;
    return RouteBadge(
      label: leg.shortName,
      color: parseGtfsColor(leg.colorHex) ?? colorScheme.primary,
      textColor: parseGtfsColor(leg.textColorHex),
      icon: mode == null
          ? null
          : Icon(
              transportModeBadgeIcon(TransportModeExtension.fromString(mode)),
            ),
      variant: RouteBadgeVariant.chip,
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

/// Card metrics: the outer shape and the icon tile are `SavedPlaceTile`'s,
/// so both lists read as one family; the badge radius is the leg chip's.
abstract final class _Dimensions {
  static const double radius = 16;
  static const double padding = 14;
  static const double iconBox = 48;
  static const double iconRadius = 14;
  static const double badgeRadius = 8;
  static const double gap = 8;
}

/// Origin above destination with the route detail's timeline (green dot,
/// dotted line, red dot — `transport_detail_screen.dart`, origin/destination
/// header). The dots say which is which, so the names carry no prefix;
/// screen readers get "Origin: …" / "Destination: …" instead.
class _Terminals extends StatelessWidget {
  const _Terminals({
    required this.origin,
    required this.destination,
    required this.localization,
  });

  final String origin;
  final String destination;
  final SavedPlacesLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // The detail's terminal colours, not theme roles: green is the
            // map's origin marker and red its destination (design contract
            // §0.1, §3.4).
            _TerminalDot(color: Colors.green, border: Colors.green.shade700),
            CustomPaint(
              size: const Size(2, 28),
              painter: _DottedLinePainter(color: colorScheme.outlineVariant),
            ),
            _TerminalDot(color: Colors.red, border: Colors.red.shade700),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: localization.routeOrigin(origin),
                excludeSemantics: true,
                child: Text(
                  origin,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: localization.routeDestination(destination),
                excludeSemantics: true,
                child: Text(
                  destination,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TerminalDot extends StatelessWidget {
  const _TerminalDot({required this.color, required this.border});

  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
    );
  }
}

/// Dotted line between the terminals — a private copy of the route detail's
/// painter: screen packages do not import each other for a widget.
class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// The itinerary card's footer chip: icon + text in onSurfaceVariant.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
