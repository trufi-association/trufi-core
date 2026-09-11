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

  /// Maximum walking distance to a stop in meters (default: 800m).
  ///
  /// Walking a few extra blocks to board a direct line usually beats a
  /// transfer (issue #926), so the radius errs on the generous side.
  final double maxWalkingDistance;

  /// Walking speed in meters per second (default: 1.2 m/s).
  final double walkSpeed;

  /// How many candidate stops to consider around the origin and the
  /// destination when searching for routes (default: 150).
  ///
  /// In dense networks a small pool truncates the search to a few hundred
  /// meters regardless of [maxWalkingDistance] — with 60 candidates a
  /// downtown query only saw stops within ~400 m, hiding boarding points
  /// of valid direct and transfer options (issues #926, #974). Measured on
  /// the heaviest real feed (Cochabamba, 657 patterns): 150 costs a few ms
  /// average per query; the worst case depends on the query mix and can
  /// roughly double (~20 → ~50 ms on desktop for the densest pairs — the
  /// direct phase scales superlinearly with the pool). Raise it further if
  /// your city has extremely dense overlapping stops, lower it to trade
  /// coverage for speed.
  final int maxStopCandidates;

  /// Most bus changes an itinerary may have (default: 1, i.e. two buses).
  ///
  /// The planner offers the fewest transfers that reach the destination:
  /// direct lines hide one-transfer options, and one-transfer options hide
  /// anything longer, so raising this never changes a trip that already
  /// plans — it only turns some "no routes" into an answer. `0` offers
  /// direct lines only. `2` is worth it on fragmented networks: Sana'a's
  /// feed is 194 short OSM-derived lines and a random ≥ 2 km pair is
  /// plannable 54 % of the time with one transfer, 77.5 % with two, 90 %
  /// with three (trufi-sanaa#2, second reopening); on Cochabamba's long
  /// crossing lines the same step is 95.8 % → 99.5 %. Cost: the extra
  /// search runs only on queries that would otherwise return nothing and
  /// took under 1 ms on Sana'a and 0.7 ms average / 12 ms worst case on
  /// the dense Cochabamba feed (desktop). Above 3 the search rarely finds
  /// anything new and stops by itself once no new line is reached. Must be
  /// >= 0. Remote mode forwards it to the server, which applies it if its
  /// planner supports it.
  final int maxTransfers;

  /// Straight-line distance, in meters, within which two distinct stops
  /// count as one transfer point (default: 100 m; local mode only).
  ///
  /// The planner only chained two lines where they shared a `stop_id`.
  /// Feeds derived from OSM give the two kerbs of a street different stop
  /// ids, so lines crossing at the same corner in opposite directions could
  /// never be combined — Sana'a lost every trip that needed such a transfer
  /// (trufi-sanaa#2). 100 m is what MOTIS uses to link nearby stops
  /// (`link_stop_distance`); `0` restores shared-stop-only transfers. The
  /// precomputed connection table grows with it — thinned to one connection
  /// per crossing, Cochabamba's dense feed holds 2.2× the shared-stop table
  /// at 100 m and 2.3× at 150 m (2.6 M / 2.8 M entries, 16 bytes each).
  final double transferRadiusMeters;

  /// Two routes with the same `route_short_name` are one line — never
  /// chained by a transfer, one itinerary row — only when at most this many
  /// `route_id`s carry that name (default: 3; local mode only).
  ///
  /// Covers the usual outbound/inbound or per-agency split (Cochabamba's
  /// "209" is `route_id` 67 and 68). Feeds built per OSM relation can give
  /// dozens of genuinely different lines one informal ref (Sana'a: 157
  /// routes named "7"); above the limit each route is its own line. Raise
  /// it if a city legitimately splits one line into more than three
  /// `route_id`s; a very large value restores the old "same name is always
  /// the same line" rule.
  final int sameNameRouteLimit;

  /// Keep the built planner index on disk between cold starts (default:
  /// true; local mode only).
  ///
  /// Parsing the bundled GTFS and building the indices runs on every cold
  /// start otherwise — ~1.6 s on a desktop VM for the Cochabamba feed,
  /// several times that on a low-end phone — and the planner is not ready
  /// until it finishes (#993). With this on, the first start after an
  /// install or update still builds once and writes a snapshot to the app's
  /// cache directory; later starts load it in a fraction of the time. The
  /// snapshot is keyed by the GTFS content, [transferRadiusMeters],
  /// [sameNameRouteLimit] and the snapshot format version, so a changed
  /// feed or engine rebuilds; anything unreadable is silently rebuilt too.
  /// Turn it off if a deployment must not write to the cache directory.
  final bool persistIndex;

  /// Create a local (offline) configuration using GTFS asset.
  const TrufiPlannerConfig.local({
    required String this.gtfsAsset,
    this.providerId,
    this.displayName,
    this.description,
    this.maxWalkingDistance = 800,
    this.walkSpeed = 1.2,
    this.maxTransfers = 1,
    this.maxStopCandidates = 150,
    this.transferRadiusMeters = 100,
    this.sameNameRouteLimit = 3,
    this.persistIndex = true,
  }) : assert(maxTransfers >= 0, 'maxTransfers must be >= 0'),
       serverUrl = null;

  /// Create a remote (online) configuration using server URL.
  ///
  /// Transfer geometry is decided by the server, so [transferRadiusMeters]
  /// and [sameNameRouteLimit] are not configurable here.
  const TrufiPlannerConfig.remote({
    required String this.serverUrl,
    this.providerId,
    this.displayName,
    this.description,
    this.maxWalkingDistance = 800,
    this.walkSpeed = 1.2,
    this.maxTransfers = 1,
    this.maxStopCandidates = 150,
  }) : assert(maxTransfers >= 0, 'maxTransfers must be >= 0'),
       gtfsAsset = null,
       transferRadiusMeters = 100,
       sameNameRouteLimit = 3,
       persistIndex = false;
}
