/// Configuration for TrufiPlannerProvider.
///
/// Supports two modes:
/// - **Local**: Load GTFS ZIP from Flutter assets (mobile/offline)
/// - **Remote**: Call trufi-server-planner HTTP API (web/online)
///
/// Example (mobile):
/// ```dart
/// TrufiPlannerConfig.local(gtfsAsset: 'assets/routing/gtfs.zip')
/// ```
///
/// Example (web):
/// ```dart
/// TrufiPlannerConfig.remote(serverUrl: 'https://planner.trufi.dev')
/// ```
class TrufiPlannerConfig {
  /// Path to GTFS ZIP file in assets (local mode only).
  final String? gtfsAsset;

  /// URL of trufi-server-planner (remote mode only).
  final String? serverUrl;

  /// Whether this is a local (offline) configuration.
  bool get isLocal => gtfsAsset != null;

  /// Whether this is a remote (online) configuration.
  bool get isRemote => serverUrl != null;

  /// Custom provider ID (default: 'trufi_planner').
  final String? providerId;

  /// Custom display name for UI.
  final String? displayName;

  /// Custom description for UI.
  final String? description;

  /// Maximum walking distance to a stop in meters (default: 500m).
  final double maxWalkingDistance;

  /// Walking speed in meters per second (default: 1.2 m/s).
  final double walkSpeed;

  /// Maximum number of transfers allowed (default: 1).
  final int maxTransfers;

  /// Create a local (offline) configuration using GTFS asset.
  const TrufiPlannerConfig.local({
    required String this.gtfsAsset,
    this.providerId,
    this.displayName,
    this.description,
    this.maxWalkingDistance = 500,
    this.walkSpeed = 1.2,
    this.maxTransfers = 1,
  }) : serverUrl = null;

  /// Create a remote (online) configuration using server URL.
  const TrufiPlannerConfig.remote({
    required String this.serverUrl,
    this.providerId,
    this.displayName,
    this.description,
    this.maxWalkingDistance = 500,
    this.walkSpeed = 1.2,
    this.maxTransfers = 1,
  }) : gtfsAsset = null;
}
