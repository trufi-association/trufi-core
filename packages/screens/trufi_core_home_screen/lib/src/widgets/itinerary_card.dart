import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/home_screen_localizations.dart';

/// Card displaying a single itinerary option with modern design.
class ItineraryCard extends StatelessWidget {
  final routing.Itinerary itinerary;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onStartNavigation;

  /// The distinct routes serving each transit slot across the itinerary's
  /// group ([routing.ItineraryGroup.slotRoutes]). When a slot carries more
  /// than one route the chip paints one segment per option, each in its
  /// own route color. The group's options are explored in the detail view.
  final List<List<routing.Route>>? slotRoutes;

  const ItineraryCard({
    super.key,
    required this.itinerary,
    required this.isSelected,
    required this.onTap,
    this.onDetailsTap,
    this.onStartNavigation,
    this.slotRoutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = HomeScreenLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Duration and time
                _buildHeaderRow(context, theme, l10n),
                const SizedBox(height: 10),
                // Transport modes summary
                _buildTransportSummary(context),
                const SizedBox(height: 8),
                // Bottom row: Distance, transfers, and details button
                _buildFooterRow(theme, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    ThemeData theme,
    HomeScreenLocalizations l10n,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Duration chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDuration(itinerary.duration, l10n),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Time range. Hidden when `routingTimeOverride` is set on the
        // app config — under that mode the routing request uses a
        // fixed time-of-day, so the resulting `startTime`/`endTime`
        // are not the user's real wall-clock and would mislead.
        if (context.watch<AppConfiguration?>()?.routingTimeOverride == null)
          Expanded(
            // FittedBox: 12-hour locales ("8:00 AM → 9:00 AM") made this
            // row overflow on ordinary phone widths — scale down instead.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatClockTime(context, itinerary.startTime),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatClockTime(context, itinerary.endTime),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        // Go button or selection indicator
        if (isSelected && onStartNavigation != null)
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onStartNavigation!();
            },
            icon: const Icon(Icons.navigation_rounded, size: 16),
            label: Text(l10n.buttonGo),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else if (isSelected)
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildTransportSummary(BuildContext context) {
    final legs = itinerary.legs;
    final theme = Theme.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final (i, chip) in _chipsWithSlotRoutes(legs).indexed) ...[
              chip,
              if (i < legs.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// One chip per leg, feeding each transit chip the distinct routes its
  /// group offers for that slot. Walk/bike legs pass through.
  List<Widget> _chipsWithSlotRoutes(List<routing.Leg> legs) {
    var transitSlot = 0;
    return legs.map((leg) {
      final slots = slotRoutes;
      final routes = leg.transitLeg && slots != null && transitSlot < slots.length
          ? slots[transitSlot++]
          : null;
      return _LegChip(leg: leg, slotRoutes: routes);
    }).toList(growable: false);
  }

  Widget _buildFooterRow(ThemeData theme, HomeScreenLocalizations l10n) {
    final walkingLegs = itinerary.legs.where(
      (leg) => leg.transportMode == routing.TransportMode.walk,
    );
    final totalWalkingMeters = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.distance.toInt(),
    );
    final transferCount = itinerary.legs.where((leg) => leg.transitLeg).length;

    return Row(
      children: [
        // Distance
        _InfoChip(
          icon: Icons.straighten_rounded,
          label: _formatDistance(itinerary.distance, l10n),
          theme: theme,
        ),
        const SizedBox(width: 8),
        // Walking distance
        if (totalWalkingMeters > 0) ...[
          _InfoChip(
            icon: Icons.directions_walk_rounded,
            label: _formatDistance(totalWalkingMeters, l10n),
            theme: theme,
          ),
          const SizedBox(width: 8),
        ],
        // Transfers
        if (transferCount > 1)
          _InfoChip(
            icon: Icons.sync_alt_rounded,
            label: '${transferCount - 1}',
            theme: theme,
          ),
        const Spacer(),
        // Details button
        if (onDetailsTap != null)
          TextButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onDetailsTap!();
            },
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            label: Text(l10n.buttonDetails),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration, HomeScreenLocalizations l10n) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return l10n.durationHoursMinutes(hours, minutes);
    }
    return l10n.durationMinutes(minutes);
  }

  String _formatDistance(int meters, HomeScreenLocalizations l10n) {
    if (meters < 1000) {
      return l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n.distanceKilometers(km);
  }
}

/// Chip showing transport leg information
class _LegChip extends StatelessWidget {
  final routing.Leg leg;

  /// Distinct routes the itinerary's group offers for this slot; when it
  /// carries more than one, the chip paints one segment per option, each
  /// in its own route color.
  final List<routing.Route>? slotRoutes;

  const _LegChip({required this.leg, this.slotRoutes});

  @override
  Widget build(BuildContext context) {
    final isWalk = leg.transportMode == routing.TransportMode.walk;
    final isBike = leg.transportMode == routing.TransportMode.bicycle;

    if (isWalk || isBike) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWalk
                  ? Icons.directions_walk_rounded
                  : Icons.directions_bike_rounded,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${leg.duration.inMinutes}\'',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Transit leg. With interchangeable routes in the slot (#737), every
    // option paints its own segment in its OWN route color, separated by
    // a drawn bar — never a "/" inside one flat-colored chip.
    final options = (slotRoutes != null && slotRoutes!.length > 1)
        ? slotRoutes!
        : null;

    if (options != null) {
      // Slanted seams ("/", Sam 2026-08-12: "la separación con /, no algo
      // vertical") — each segment is a parallelogram; consecutive edges
      // run parallel, so the sliver of background between them draws the
      // diagonal divider.
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, route) in options.indexed) ...[
              if (i > 0) const SizedBox(width: 2),
              ClipPath(
                clipper: _SlantEdgeClipper(
                  slantLeading: i > 0,
                  slantTrailing: i < options.length - 1,
                ),
                child: _routeSegment(
                  route,
                  withIcon: i == 0,
                  mode: leg.transportMode,
                  slantLeading: i > 0,
                  slantTrailing: i < options.length - 1,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final color = _getRouteColor(leg);
    final textColor = _contrastOn(color);
    final routeName = leg.shortName ?? leg.route?.shortName ?? '';
    final realtime = context.watch<RealtimeVehiclesProvider?>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getModeIcon(leg.transportMode), size: 16, color: textColor),
          if (routeName.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              routeName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
          if (realtime != null) ...[
            const SizedBox(width: 6),
            LiveBusBadge.whenLive(
              provider: realtime,
              leg: leg,
              color: textColor,
              size: 10,
            ),
          ],
        ],
      ),
    );
  }

  /// One colored segment of a multi-route chip: the option's own route
  /// color with its name (the mode icon only leads the first segment).
  /// Slanted edges get extra padding so the text clears the diagonal cut.
  Widget _routeSegment(
    routing.Route route, {
    required bool withIcon,
    required routing.TransportMode mode,
    bool slantLeading = false,
    bool slantTrailing = false,
  }) {
    final color = _routeOwnColor(route, mode);
    final textColor = _contrastOn(color);
    final name = route.shortName ?? '';
    return Container(
      padding: EdgeInsets.only(
        left: slantLeading ? 8 + _SlantEdgeClipper.slant : 8,
        right: slantTrailing ? 8 + _SlantEdgeClipper.slant : 8,
        top: 4,
        bottom: 4,
      ),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(_getModeIcon(mode), size: 16, color: textColor),
            if (name.isNotEmpty) const SizedBox(width: 4),
          ],
          if (name.isNotEmpty)
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  static Color _contrastOn(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  Color _routeOwnColor(routing.Route route, routing.TransportMode mode) {
    final colorStr = route.color ?? '';
    // Empty guard: 'FF' alone parses to a transparent blue and would make
    // the mode-color fallback unreachable.
    final parsed = colorStr.isNotEmpty
        ? int.tryParse('FF$colorStr', radix: 16)
        : null;
    if (parsed != null) return Color(parsed);
    return _getModeColor(mode);
  }

  Color _getRouteColor(routing.Leg leg) {
    final colorStr = leg.routeColor;
    final parsed = int.tryParse('FF$colorStr', radix: 16);
    if (parsed != null) return Color(parsed);
    return _getModeColor(leg.transportMode);
  }

  Color _getModeColor(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
        return const Color(0xFF1976D2);
      case routing.TransportMode.rail:
      case routing.TransportMode.subway:
        return const Color(0xFFE65100);
      case routing.TransportMode.tram:
        return const Color(0xFFC62828);
      case routing.TransportMode.ferry:
        return const Color(0xFF00838F);
      default:
        return Colors.grey;
    }
  }

  IconData _getModeIcon(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
        return Icons.directions_bus_rounded;
      case routing.TransportMode.rail:
        return Icons.train_rounded;
      case routing.TransportMode.subway:
        return Icons.subway_rounded;
      case routing.TransportMode.tram:
        return Icons.tram_rounded;
      case routing.TransportMode.ferry:
        return Icons.directions_boat_rounded;
      case routing.TransportMode.walk:
        return Icons.directions_walk_rounded;
      case routing.TransportMode.bicycle:
        return Icons.directions_bike_rounded;
      default:
        return Icons.directions_rounded;
    }
  }
}

/// Clips a chip segment into a parallelogram: the leading/trailing edges
/// run at the same diagonal, so two adjacent segments separated by a thin
/// gap read as a "/" seam.
class _SlantEdgeClipper extends CustomClipper<Path> {
  const _SlantEdgeClipper({
    required this.slantLeading,
    required this.slantTrailing,
  });

  /// Horizontal run of the diagonal edge, in logical pixels.
  static const double slant = 6;

  final bool slantLeading;
  final bool slantTrailing;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(slantLeading ? slant : 0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - (slantTrailing ? slant : 0), size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_SlantEdgeClipper oldClipper) =>
      oldClipper.slantLeading != slantLeading ||
      oldClipper.slantTrailing != slantTrailing;
}

/// Small info chip for footer
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

