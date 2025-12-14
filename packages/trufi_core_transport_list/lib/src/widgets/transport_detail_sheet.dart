import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transport_route.dart';

/// Bottom sheet showing transport route stops with modern timeline design
class TransportDetailSheet extends StatelessWidget {
  final TransportRouteDetails route;
  final void Function(double lat, double lng)? onStopTap;

  const TransportDetailSheet({
    super.key,
    required this.route,
    this.onStopTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stops = route.stops ?? [];

    if (stops.isEmpty) {
      return _EmptyStopsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        final isFirst = index == 0;
        final isLast = index == stops.length - 1;
        final routeColor = route.backgroundColor ?? colorScheme.primary;

        return _StopTimelineItem(
          stop: stop,
          isFirst: isFirst,
          isLast: isLast,
          routeColor: routeColor,
          onTap: onStopTap != null
              ? () {
                  HapticFeedback.selectionClick();
                  onStopTap!(stop.latitude, stop.longitude);
                }
              : null,
        );
      },
    );
  }
}

/// Modern timeline stop item with enhanced visuals
class _StopTimelineItem extends StatelessWidget {
  final TransportStop stop;
  final bool isFirst;
  final bool isLast;
  final Color routeColor;
  final VoidCallback? onTap;

  const _StopTimelineItem({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.routeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline track
                SizedBox(
                  width: 32,
                  child: _TimelineTrack(
                    isFirst: isFirst,
                    isLast: isLast,
                    routeColor: routeColor,
                  ),
                ),
                const SizedBox(width: 16),

                // Stop content
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: isFirst ? 0 : 4,
                      bottom: isLast ? 0 : 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (isFirst || isLast)
                          ? routeColor.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: (isFirst || isLast)
                          ? Border.all(
                              color: routeColor.withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Stop type label for first/last
                              if (isFirst || isLast)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: routeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isFirst ? 'Start' : 'End',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: routeColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              // Stop name
                              Text(
                                stop.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: (isFirst || isLast)
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tap indicator
                        if (onTap != null)
                          Icon(
                            Icons.my_location_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Timeline track with line and node
class _TimelineTrack extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color routeColor;

  const _TimelineTrack({
    required this.isFirst,
    required this.isLast,
    required this.routeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top line
        Expanded(
          child: Container(
            width: 3,
            decoration: BoxDecoration(
              color: isFirst ? Colors.transparent : routeColor.withValues(alpha: 0.4),
              borderRadius: isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(2))
                  : null,
            ),
          ),
        ),

        // Node
        _TimelineNode(
          isTerminal: isFirst || isLast,
          routeColor: routeColor,
          isStart: isFirst,
        ),

        // Bottom line
        Expanded(
          child: Container(
            width: 3,
            decoration: BoxDecoration(
              color: isLast ? Colors.transparent : routeColor.withValues(alpha: 0.4),
              borderRadius: isFirst
                  ? const BorderRadius.vertical(top: Radius.circular(2))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Timeline node (dot) for stops
class _TimelineNode extends StatelessWidget {
  final bool isTerminal;
  final Color routeColor;
  final bool isStart;

  const _TimelineNode({
    required this.isTerminal,
    required this.routeColor,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isTerminal) {
      // Terminal node (start/end) - larger with icon
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: routeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: routeColor.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isStart ? Icons.trip_origin_rounded : Icons.location_on_rounded,
          size: 16,
          color: Colors.white,
        ),
      );
    }

    // Regular stop node
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: routeColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}

/// Empty state when no stops available
class _EmptyStopsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 32,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No stops available',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stop information is not available for this route',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
