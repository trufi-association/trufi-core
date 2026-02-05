import 'package:flutter/material.dart';

import '../models/transport_route.dart';

/// Modern tile widget displaying a transport route in the list
class TransportTile extends StatelessWidget {
  final TransportRoute route;
  final VoidCallback onTap;

  const TransportTile({
    super.key,
    required this.route,
    required this.onTap,
  });

  /// Get the primary text to display (destination or route name)
  String _getPrimaryText(TransportRoute route) {
    // If has origin → destination format, show destination
    if (route.hasOriginDestination) {
      return route.longNameLast;
    }
    // Otherwise show the long name or name
    if (route.longName != null && route.longName!.isNotEmpty) {
      return route.longName!;
    }
    return route.name;
  }

  /// Get the secondary text (origin → destination or null)
  String? _getSecondaryText(TransportRoute route) {
    if (route.hasOriginDestination) {
      return '${route.longNameStart} → ${route.longNameLast}';
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
                      _RouteBadge(route: route),
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
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _getSecondaryText(route)!,
                                      style: theme.textTheme.bodySmall?.copyWith(
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
                          ],
                        ),
                      ),

                      // Chevron indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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

/// Modern route badge with transport type icon
class _RouteBadge extends StatelessWidget {
  final TransportRoute route;

  const _RouteBadge({required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final routeColor = route.backgroundColor ?? colorScheme.primary;
    final textColor = route.textColor ?? _getContrastColor(routeColor);

    return Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: routeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: routeColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Transport mode icon
          if (route.modeIcon != null)
            SizedBox(
              width: 18,
              height: 18,
              child: IconTheme(
                data: IconThemeData(color: textColor, size: 18),
                child: route.modeIcon!,
              ),
            )
          else
            Icon(
              Icons.directions_bus_rounded,
              size: 18,
              color: textColor,
            ),
          const SizedBox(height: 2),
          // Route number
          Text(
            route.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Calculate contrast color for text based on background
  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
