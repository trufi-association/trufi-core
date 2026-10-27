import 'package:flutter/material.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show ServiceHoursIndicator;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show RouteBadge;

import '../models/transport_route.dart';

/// Modern tile widget displaying a transport route in the list
class TransportTile extends StatelessWidget {
  final TransportRoute route;
  final VoidCallback onTap;

  const TransportTile({super.key, required this.route, required this.onTap});

  /// Primary title — corridor descriptor.
  ///
  /// Prefer `route_long_name` (e.g. "Trufi 134"). When the feed has
  /// no long name, fall back to the trip headsign (typical for feeds
  /// where each relation is named only by direction). Last resort is
  /// the generic `name` field.
  String _getPrimaryText(TransportRoute route) {
    if (route.longName != null && route.longName!.isNotEmpty) {
      return route.longName!;
    }
    if (route.headsign != null && route.headsign!.isNotEmpty) {
      return route.headsign!;
    }
    return route.name;
  }

  /// Subtitle — variant or destination of the specific trip.
  ///
  /// Only emitted when the primary line is `route_long_name`. Prefer
  /// `trip_headsign` (carries the OSM `description` variant when set,
  /// e.g. "Verde", "Bandera Roja"; otherwise the OSM `to` tag).
  /// Falls back to `route_desc` when present.
  String? _getSecondaryText(TransportRoute route) {
    final hasLongName = route.longName != null && route.longName!.isNotEmpty;
    if (!hasLongName) return null;
    if (route.headsign != null && route.headsign!.isNotEmpty) {
      return route.headsign;
    }
    if (route.description != null && route.description!.isNotEmpty) {
      return route.description;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final routeColor = route.backgroundColor ?? colorScheme.primary;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: routeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    children: [
                      // Route badge with icon
                      RouteBadge(
                        label: route.displayName,
                        color: routeColor,
                        textColor: route.textColor,
                        icon: route.modeIcon,
                      ),
                      const SizedBox(width: 14),

                      // Route info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Primary info: destination or route name
                            Text(
                              _getPrimaryText(route),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Secondary info: origin → destination or long name
                            if (_getSecondaryText(route) != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _getSecondaryText(route)!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.3,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Service status indicator (when feed has
                            // calendar + frequencies). Always evaluates
                            // against `DateTime.now()`, independent of
                            // the app's `routingTimeOverride`, so the
                            // user sees whether the bus runs *right now*.
                            if (route.serviceHours != null) ...[
                              const SizedBox(height: 4),
                              ServiceHoursIndicator(
                                serviceHours: route.serviceHours!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Chevron indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ],
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

