import 'package:flutter/material.dart';

import '../models/transport_route.dart';

/// Bottom sheet showing transport route stops
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No stops available',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: route.backgroundColor ?? colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  route.displayName,
                  style: TextStyle(
                    color: route.textColor ?? colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${stops.length} stops',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Stops list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final isFirst = index == 0;
              final isLast = index == stops.length - 1;

              return InkWell(
                onTap: onStopTap != null
                    ? () => onStopTap!(stop.latitude, stop.longitude)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      // Timeline indicator
                      SizedBox(
                        width: 24,
                        child: Column(
                          children: [
                            Container(
                              width: 2,
                              height: 12,
                              color: isFirst
                                  ? Colors.transparent
                                  : route.backgroundColor ?? colorScheme.primary,
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isFirst || isLast)
                                    ? route.backgroundColor ?? colorScheme.primary
                                    : colorScheme.surface,
                                border: Border.all(
                                  color: route.backgroundColor ?? colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 12,
                              color: isLast
                                  ? Colors.transparent
                                  : route.backgroundColor ?? colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Stop name
                      Expanded(
                        child: Text(
                          stop.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: (isFirst || isLast)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
