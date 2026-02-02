import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import '../../l10n/home_screen_localizations.dart';

/// Content widget for displaying itinerary details inline (without Scaffold).
/// Use this when you want to show details within an existing panel/sheet.
class ItineraryDetailContent extends StatelessWidget {
  final routing.Itinerary itinerary;
  final VoidCallback? onBack;
  final VoidCallback? onStartNavigation;

  /// When true, the content will shrink to fit and disable its own scrolling.
  /// Use this when the content is inside a parent scrollable.
  final bool shrinkWrap;

  const ItineraryDetailContent({
    super.key,
    required this.itinerary,
    this.onBack,
    this.onStartNavigation,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Header
        _buildHeader(context, theme, colorScheme, l10n),
        const SizedBox(height: 8),
        // Subtle separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.outlineVariant.withValues(alpha: 0.0),
                colorScheme.outlineVariant.withValues(alpha: 0.5),
                colorScheme.outlineVariant.withValues(alpha: 0.5),
                colorScheme.outlineVariant.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.15, 0.85, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Timeline
        _VerticalTimeline(itinerary: itinerary, l10n: l10n),
      ],
    );

    if (shrinkWrap) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: content,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    HomeScreenLocalizations l10n,
  ) {
    final duration = itinerary.duration;
    final durationText = duration.inHours > 0
        ? l10n.durationHoursMinutes(
            duration.inHours, duration.inMinutes.remainder(60))
        : l10n.durationMinutes(duration.inMinutes);

    // Calculate total walking
    final walkingLegs = itinerary.legs.where(
      (leg) => leg.transportMode == routing.TransportMode.walk,
    );
    final totalWalkingMeters = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.distance.toInt(),
    );
    final transferCount =
        itinerary.legs.where((leg) => leg.transitLeg).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Back button, Duration chip, Time range, Go button
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onBack?.call();
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              // Duration chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  durationText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Time range
              Text(
                DateFormat('HH:mm').format(itinerary.startTime),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(itinerary.endTime),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Go button
              if (onStartNavigation != null)
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onStartNavigation!();
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Go'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    textStyle:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Distance, Walking, Transfers, CO2
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                // Distance
                Icon(
                  Icons.straighten_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDistance(itinerary.distance, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                // Walking distance
                if (totalWalkingMeters > 0) ...[
                  Icon(
                    Icons.directions_walk_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(totalWalkingMeters, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Transfers
                if (transferCount > 1) ...[
                  Icon(
                    Icons.sync_alt_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${transferCount - 1}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // CO2 emissions
                if (itinerary.emissionsPerPerson != null &&
                    itinerary.emissionsPerPerson! > 0) ...[
                  Icon(
                    Icons.eco_rounded,
                    size: 14,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.co2Emissions(
                        itinerary.emissionsPerPerson!.toStringAsFixed(0)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(int meters, HomeScreenLocalizations l10n) {
    if (meters < 1000) {
      return l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n.distanceKilometers(km);
  }
}

/// Vertical timeline showing all legs with icons on the left.
class _VerticalTimeline extends StatelessWidget {
  final routing.Itinerary itinerary;
  final HomeScreenLocalizations l10n;

  const _VerticalTimeline({required this.itinerary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final legs = itinerary.legs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for (int i = 0; i < legs.length; i++) ...[
            // Origin (only first leg)
            if (i == 0)
              _PlaceItem(
                place: legs[i].fromPlace,
                dotColor: const Color(0xFFE91E63),
                isOrigin: true,
                lineColorBelow: _getLegColor(legs[i], colorScheme),
                time: legs[i].fromPlace?.departureTime,
              ),

            // Leg
            _LegItem(
              leg: legs[i],
              l10n: l10n,
              lineColor: _getLegColor(legs[i], colorScheme),
            ),

            // Destination / Transfer
            _PlaceItem(
              place: legs[i].toPlace,
              dotColor: i == legs.length - 1
                  ? const Color(0xFFE91E63) // Destination
                  : _getLegColor(legs[i + 1], colorScheme), // Transfer
              isDestination: i == legs.length - 1,
              lineColorAbove: _getLegColor(legs[i], colorScheme),
              lineColorBelow: i < legs.length - 1
                  ? _getLegColor(legs[i + 1], colorScheme)
                  : null,
              time: legs[i].toPlace?.arrivalTime,
            ),
          ],
        ],
      ),
    );
  }

  Color _getLegColor(routing.Leg leg, ColorScheme colorScheme) {
    if (leg.transportMode == routing.TransportMode.walk ||
        leg.transportMode == routing.TransportMode.bicycle) {
      return colorScheme.outlineVariant;
    }
    if (leg.routeColor.isNotEmpty) {
      final parsed = int.tryParse('FF${leg.routeColor}', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return _getModeColor(leg.transportMode);
  }

  Color _getModeColor(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
        return const Color(0xFFE91E63);
      case routing.TransportMode.rail:
      case routing.TransportMode.subway:
        return const Color(0xFF4CAF50);
      case routing.TransportMode.tram:
        return const Color(0xFFFF5722);
      case routing.TransportMode.ferry:
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF2196F3);
    }
  }
}

/// Place item (origin, transfer, or destination).
class _PlaceItem extends StatelessWidget {
  final routing.Place? place;
  final Color dotColor;
  final bool isOrigin;
  final bool isDestination;
  final Color? lineColorAbove;
  final Color? lineColorBelow;
  final DateTime? time;

  const _PlaceItem({
    required this.place,
    required this.dotColor,
    this.isOrigin = false,
    this.isDestination = false,
    this.lineColorAbove,
    this.lineColorBelow,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Icon column (empty for places)
        const SizedBox(width: 32),
        // Timeline column - use Icon for destination, CustomPaint for others
        SizedBox(
          width: 20,
          height: 32,
          child: isDestination
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Line above
                    if (lineColorAbove != null)
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 4,
                          height: 10,
                          color: lineColorAbove,
                        ),
                      ),
                    // Pin icon
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: dotColor,
                    ),
                  ],
                )
              : CustomPaint(
                  painter: _DotLinePainter(
                    dotColor: dotColor,
                    lineColorAbove: lineColorAbove,
                    lineColorBelow: lineColorBelow,
                    isOrigin: isOrigin,
                    isDestination: false,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Place name
        Expanded(
          child: Text(
            place?.name ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Time
        if (time != null)
          Text(
            DateFormat('HH:mm').format(time!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Custom painter for dot and lines.
class _DotLinePainter extends CustomPainter {
  final Color dotColor;
  final Color? lineColorAbove;
  final Color? lineColorBelow;
  final bool isOrigin;
  final bool isDestination;

  _DotLinePainter({
    required this.dotColor,
    this.lineColorAbove,
    this.lineColorBelow,
    this.isOrigin = false,
    this.isDestination = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const lineWidth = 4.0;
    const dotRadius = 6.0;

    // Line above
    if (lineColorAbove != null) {
      final paint = Paint()
        ..color = lineColorAbove!
        ..strokeWidth = lineWidth;
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, centerY - dotRadius),
        paint,
      );
    }

    // Line below
    if (lineColorBelow != null) {
      final paint = Paint()
        ..color = lineColorBelow!
        ..strokeWidth = lineWidth;
      canvas.drawLine(
        Offset(centerX, centerY + dotRadius),
        Offset(centerX, size.height),
        paint,
      );
    }

    // Dot
    if (isOrigin) {
      // Origin: outlined circle
      final paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
    } else if (isDestination) {
      // Destination: filled circle with border
      final fillPaint = Paint()..color = dotColor;
      final borderPaint = Paint()
        ..color = dotColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, fillPaint);
      canvas.drawCircle(Offset(centerX, centerY), dotRadius + 2, borderPaint);
    } else {
      // Transfer: filled circle
      final paint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Leg item (walking or transit).
class _LegItem extends StatefulWidget {
  final routing.Leg leg;
  final HomeScreenLocalizations l10n;
  final Color lineColor;

  const _LegItem({
    required this.leg,
    required this.l10n,
    required this.lineColor,
  });

  @override
  State<_LegItem> createState() => _LegItemState();
}

class _LegItemState extends State<_LegItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final leg = widget.leg;
    final isWalk = leg.transportMode == routing.TransportMode.walk;
    final isBike = leg.transportMode == routing.TransportMode.bicycle;
    final hasStops =
        leg.intermediatePlaces != null && leg.intermediatePlaces!.isNotEmpty;
    final stopsCount = leg.intermediatePlaces?.length ?? 0;

    return Column(
      children: [
        // Main leg row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Timeline column
            Column(
              children: [
                // Icon (only for walking/biking)
                SizedBox(
                  width: 32,
                  height: 24,
                  child: (isWalk || isBike)
                      ? Icon(
                          _getModeIcon(leg.transportMode),
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ],
            ),
            // Timeline line with fixed height based on content type
            SizedBox(
              width: 20,
              height: (isWalk || isBike) ? 32 : 90,
              child: Center(
                child: Container(
                  width: 4,
                  color: (isWalk || isBike)
                      ? widget.lineColor.withValues(alpha: 0.5)
                      : widget.lineColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Leg content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: _buildLegContent(
                  theme,
                  colorScheme,
                  isWalk,
                  isBike,
                  hasStops,
                  stopsCount,
                ),
              ),
            ),
          ],
        ),

        // Expanded stops
        if (_isExpanded && hasStops) _buildExpandedStops(theme, colorScheme),
      ],
    );
  }

  Widget _buildLegContent(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isWalk,
    bool isBike,
    bool hasStops,
    int stopsCount,
  ) {
    final leg = widget.leg;
    final durationText = _formatDuration(leg.duration);
    final distanceText = _formatDistance(leg.distance.toInt());

    if (isWalk || isBike) {
      // Walking/biking: simple text
      return Text(
        '${isWalk ? widget.l10n.walk : widget.l10n.bike} $durationText ($distanceText)',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Get route name - prefer routeLongName, fallback to headsign
    final routeName = leg.routeLongName ?? leg.headsign;

    // Transit leg - badge on first row, info below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: badge + stops count
        Row(
          children: [
            // Route badge with icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: widget.lineColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getModeIcon(leg.transportMode),
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    leg.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Duration and distance
            Text(
              '$durationText, $distanceText',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            // Stops count (tappable)
            if (hasStops)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isExpanded = !_isExpanded);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$stopsCount ${widget.l10n.stops}',
                      style: TextStyle(
                        color: widget.lineColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: widget.lineColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Second row: route name (if available)
        if (routeName != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              routeName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Third row: Agency info (if available)
        if (leg.agency?.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              widget.l10n.operatedBy(leg.agency!.name!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        // Fourth row: Fare link (if available)
        if (leg.agency?.fareUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () {
                // TODO: Launch URL
                HapticFeedback.lightImpact();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.l10n.viewFares,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedStops(ThemeData theme, ColorScheme colorScheme) {
    final stops = widget.leg.intermediatePlaces!;

    return Column(
      children: [
        for (final stop in stops)
          SizedBox(
            height: 28,
            child: Row(
              children: [
                // Icon column (empty)
                const SizedBox(width: 32),
                // Timeline line with small dot
                SizedBox(
                  width: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vertical line
                      Container(
                        width: 4,
                        color: widget.lineColor.withValues(alpha: 0.3),
                      ),
                      // Small bullet
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.lineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Stop name
                Expanded(
                  child: Text(
                    stop.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Time
                if (stop.arrivalTime != null)
                  Text(
                    DateFormat('HH:mm').format(stop.arrivalTime!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getModeIcon(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.walk:
        return Icons.directions_walk_rounded;
      case routing.TransportMode.bicycle:
        return Icons.directions_bike_rounded;
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
      default:
        return Icons.directions_transit_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return widget.l10n.durationHoursMinutes(hours, minutes);
    }
    return widget.l10n.durationMinutes(minutes);
  }

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return widget.l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return widget.l10n.distanceKilometers(km);
  }
}

/// Screen showing detailed information about an itinerary (full screen).
class ItineraryDetailScreen extends StatelessWidget {
  final routing.Itinerary itinerary;
  final VoidCallback? onStartNavigation;

  const ItineraryDetailScreen({
    super.key,
    required this.itinerary,
    this.onStartNavigation,
  });

  /// Shows the itinerary detail screen with a slide transition.
  static Future<void> show(
    BuildContext context, {
    required routing.Itinerary itinerary,
    VoidCallback? onStartNavigation,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ItineraryDetailScreen(
          itinerary: itinerary,
          onStartNavigation: onStartNavigation,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    final duration = itinerary.duration;
    final durationText = duration.inHours > 0
        ? l10n.durationHoursMinutes(
            duration.inHours, duration.inMinutes.remainder(60))
        : l10n.durationMinutes(duration.inMinutes);

    // Calculate total walking
    final walkingLegs = itinerary.legs.where(
      (leg) => leg.transportMode == routing.TransportMode.walk,
    );
    final totalWalkingMinutes = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.duration.inMinutes,
    );
    final totalWalkingMeters = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.distance.toInt(),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Icon(Icons.schedule_rounded, size: 20, color: colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              durationText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text(
                  '$totalWalkingMinutes min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDistance(totalWalkingMeters, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: _VerticalTimeline(itinerary: itinerary, l10n: l10n),
      ),
    );
  }

  String _formatDistance(int meters, HomeScreenLocalizations l10n) {
    if (meters < 1000) {
      return l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n.distanceKilometers(km);
  }
}
