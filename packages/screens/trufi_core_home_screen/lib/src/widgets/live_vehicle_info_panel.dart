import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../../l10n/home_screen_localizations.dart';

/// Bottom-sheet content shown when the user taps a live vehicle marker.
///
/// Kept as a public, self-contained widget so it can be widget-tested
/// without pumping the whole home screen (which needs a map engine).
class LiveVehicleInfoPanel extends StatelessWidget {
  const LiveVehicleInfoPanel({
    super.key,
    required this.vehicle,
    this.color,
    this.now,
  });

  final VehiclePosition vehicle;

  /// Marker color (falls back to the theme's primary color).
  final Color? color;

  /// Injectable clock for tests; defaults to [DateTime.now].
  final DateTime? now;

  /// GTFS ids arrive as `<feedId>:<id>` (e.g. `1:1132`); the feed prefix
  /// means nothing to a rider.
  static String displayRoute(String? routeId) {
    if (routeId == null || routeId.isEmpty) return '';
    final colon = routeId.indexOf(':');
    return colon >= 0 ? routeId.substring(colon + 1) : routeId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = HomeScreenLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    final route = displayRoute(vehicle.routeId);

    final details = <Widget>[];
    if (vehicle.speed != null) {
      // GTFS-RT speeds are meters/second on the wire.
      final kmh = (vehicle.speed! * 3.6).round();
      details.add(_row(theme, Icons.speed_rounded, l10n.liveVehicleSpeed(kmh)));
    }
    if (vehicle.timestamp != null) {
      final age = (now ?? DateTime.now()).difference(vehicle.timestamp!);
      final text = age.inSeconds < 120
          ? l10n.liveVehicleUpdatedSeconds(age.inSeconds.clamp(0, 3600))
          : l10n.liveVehicleUpdatedMinutes(age.inMinutes);
      details.add(_row(theme, Icons.update_rounded, text));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accent,
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.isNotEmpty
                            ? l10n.liveVehicleRouteTitle(route)
                            : l10n.liveVehicleTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicle.label != null && vehicle.label!.isNotEmpty)
                        Text(
                          vehicle.label!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.liveVehicleLiveBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...details,
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
