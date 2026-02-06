/// Configuration for GTFS-based offline routing.
///
/// This configuration specifies the asset path for the GTFS ZIP file
/// containing transit data (stops.txt, routes.txt, trips.txt, etc.).
///
/// Example:
/// ```dart
/// const config = GtfsRoutingConfig(
///   gtfsAsset: 'assets/routing/gtfs.zip',
///   displayName: 'Offline (GTFS)',
/// );
/// ```
class GtfsRoutingConfig {
  /// Path to GTFS ZIP file in assets.
  ///
  /// The ZIP file should contain standard GTFS files:
  /// - stops.txt (required)
  /// - routes.txt (required)
  /// - trips.txt (required)
  /// - stop_times.txt (required)
  /// - calendar.txt or calendar_dates.txt (required)
  /// - shapes.txt (optional, for route geometry)
  /// - frequencies.txt (optional, for headway-based schedules)
  /// - agency.txt (optional)
  final String gtfsAsset;

  /// Custom provider ID (default: 'gtfs').
  final String? providerId;

  /// Custom display name for UI.
  final String? displayName;

  /// Custom description for UI.
  final String? description;

  /// Maximum walking distance to a stop in meters (default: 500m).
  final double maxWalkingDistance;

  /// Walking speed in meters per second (default: 1.2 m/s ≈ 4.3 km/h).
  final double walkSpeed;

  /// Maximum number of transfers allowed (default: 1).
  final int maxTransfers;

  /// Whether to preload data at startup (default: true).
  ///
  /// When true, the GTFS data will be parsed and indexed when the
  /// provider is first accessed, keeping it in memory for fast queries.
  final bool preloadAtStartup;

  const GtfsRoutingConfig({
    required this.gtfsAsset,
    this.providerId,
    this.displayName,
    this.description,
    this.maxWalkingDistance = 500,
    this.walkSpeed = 1.2,
    this.maxTransfers = 1,
    this.preloadAtStartup = true,
  });
}
