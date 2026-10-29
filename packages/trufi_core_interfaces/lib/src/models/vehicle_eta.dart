import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'realtime_vehicles_provider.dart' show stripGtfsFeedPrefix;
import 'trufi_latlng.dart';

/// Next-vehicle estimate for one route, as answered by a telemetry source
/// (a GTFS-RT derived estimate, SIRI, a city's fleet-telemetry API, ...).
class VehicleEta extends Equatable {
  const VehicleEta({
    required this.routeId,
    required this.eta,
    required this.timestamp,
    this.vehicleId,
    this.distanceMeters,
    this.stopId,
  });

  /// GTFS route id exactly as the SOURCE reports it — prefixed (`1:1132`,
  /// OTP) or bare (`1132`, bundled GTFS). Compare with [matchesRoute], never
  /// with `==`, so both spellings of the same route find each other.
  final String routeId;

  /// Time until the vehicle reaches the rider's boarding stop — the
  /// request's boarding point for this route — or the rider's origin when
  /// the request carried no boarding point (see
  /// [VehicleEtaRequest.pointFor]). Never negative.
  final Duration eta;

  /// When the estimate was produced (the source's clock when it reports
  /// one, otherwise the moment the answer was received).
  final DateTime timestamp;

  /// Identifier of the vehicle the estimate refers to, when known.
  final String? vehicleId;

  /// Straight-line or road distance from the vehicle to the point [eta]
  /// is measured to, when the source reports it.
  final double? distanceMeters;

  /// Boarding stop the estimate refers to, when the source reports it.
  final String? stopId;

  /// Minutes to display: ceiling, floored at 1. "~N min" reads as "at most
  /// N", so a vehicle 10 s away is "~1 min" — never "~0 min".
  int get minutes => math.max(1, (eta.inSeconds / 60).ceil());

  /// Feed-prefix agnostic route match (see [stripGtfsFeedPrefix]).
  bool matchesRoute(String routeGtfsId) =>
      stripGtfsFeedPrefix(routeId) == stripGtfsFeedPrefix(routeGtfsId);

  @override
  List<Object?> get props => [
    routeId,
    eta,
    timestamp,
    vehicleId,
    distanceMeters,
    stopId,
  ];

  @override
  String toString() =>
      'VehicleEta($routeId, ${eta.inSeconds}s, vehicle=$vehicleId)';
}

/// One query: the rider's origin, the routes to answer for and, per route,
/// the boarding point the planner picked. [stopIds] is an optional hint (the
/// boarding stops' ids) for sources that estimate per stop instead of per
/// coordinate; [boardingPoints] carries their coordinates for sources that
/// measure distances themselves.
class VehicleEtaRequest extends Equatable {
  const VehicleEtaRequest({
    required this.origin,
    required this.routeIds,
    this.stopIds,
    this.boardingPoints,
  });

  /// Where the rider is (the plan's origin).
  final TrufiLatLng origin;

  /// Route ids as the planner reports them (prefixed or bare); sources
  /// match them feed-agnostically.
  final Set<String> routeIds;

  final Set<String>? stopIds;

  /// Boarding stop per route, keyed by the route id as it appears in
  /// [routeIds] (either spelling; look up with [pointFor]). A source that
  /// measures distances answers "when does the vehicle reach my stop"
  /// instead of "when does it reach me" — on an itinerary with a long walk
  /// to the stop those differ by minutes. Optional and backwards
  /// compatible: routes missing here fall back to [origin].
  final Map<String, TrufiLatLng>? boardingPoints;

  /// The point the ETA of [routeId] is measured to: its boarding point when
  /// the request carries one, otherwise [origin]. Feed-prefix agnostic, so
  /// `1:1132` finds a point stored under `1132` and vice versa.
  TrufiLatLng pointFor(String routeId) {
    final points = boardingPoints;
    if (points == null || points.isEmpty) return origin;
    final direct = points[routeId];
    if (direct != null) return direct;
    final want = stripGtfsFeedPrefix(routeId);
    for (final entry in points.entries) {
      if (stripGtfsFeedPrefix(entry.key) == want) return entry.value;
    }
    return origin;
  }

  @override
  List<Object?> get props => [origin, routeIds, stopIds, boardingPoints];
}

/// The answer to one [VehicleEtaRequest]: at most a few [VehicleEta]s and
/// the time the snapshot was taken. An empty [etas] list means "no vehicle
/// reporting" — a valid answer, not an error.
class VehicleEtaSnapshot extends Equatable {
  const VehicleEtaSnapshot({
    required this.etas,
    required this.fetchedAt,
    this.source,
  });

  /// Snapshot with no estimates (the source answered, nothing matched).
  factory VehicleEtaSnapshot.empty(DateTime fetchedAt, {String? source}) =>
      VehicleEtaSnapshot(etas: const [], fetchedAt: fetchedAt, source: source);

  final List<VehicleEta> etas;
  final DateTime fetchedAt;

  /// Free-form identifier of the backend that produced the snapshot
  /// (e.g. `realtime_vehicles`), for diagnostics only.
  final String? source;

  @override
  List<Object?> get props => [etas, fetchedAt, source];
}

/// Convenience queries on top of [VehicleEtaSnapshot.etas]. All route
/// matching is feed-prefix agnostic — see [stripGtfsFeedPrefix].
extension VehicleEtaSnapshotQueries on VehicleEtaSnapshot {
  /// The soonest estimate for [routeGtfsId], or null when no vehicle of that
  /// route is reporting.
  VehicleEta? etaForRoute(String routeGtfsId) {
    VehicleEta? best;
    for (final candidate in etas) {
      if (!candidate.matchesRoute(routeGtfsId)) continue;
      if (best == null || candidate.eta < best.eta) best = candidate;
    }
    return best;
  }

  /// Soonest estimate per route, keyed by the prefix-stripped route id so a
  /// lookup with either spelling of the id hits the same entry.
  Map<String, VehicleEta> get bestEtaByRoute {
    final best = <String, VehicleEta>{};
    for (final candidate in etas) {
      final key = stripGtfsFeedPrefix(candidate.routeId);
      final current = best[key];
      if (current == null || candidate.eta < current.eta) {
        best[key] = candidate;
      }
    }
    return best;
  }
}

/// Typed failure every [VehicleEtaProvider] throws when it cannot answer
/// (network, HTTP status, malformed body, upstream error). The UI maps it to
/// its "live ETA unavailable" fallback instead of surfacing the message.
class VehicleEtaException implements Exception {
  const VehicleEtaException(this.message, {this.statusCode, this.cause});

  final String message;

  /// HTTP status when the failure came from a server answer.
  final int? statusCode;

  /// Underlying error (socket exception, timeout, parser error...).
  final Object? cause;

  @override
  String toString() {
    final status = statusCode != null ? ' (HTTP $statusCode)' : '';
    final origin = cause != null ? ': $cause' : '';
    return 'VehicleEtaException: $message$status$origin';
  }
}

/// Contract for any vehicle-telemetry backend able to answer "when does the
/// next vehicle of route R reach the rider's boarding stop?" (a GTFS-RT derived estimate,
/// SIRI, a city's fleet-telemetry API, ...).
///
/// On-demand snapshot only: one request, one answer. No streams and no
/// background polling by design (issue #1004 keeps mobile data and battery
/// usage low); callers decide when to ask again.
abstract class VehicleEtaProvider {
  /// Answers [request]. Returns an empty snapshot when no vehicle of the
  /// requested routes is reporting; throws [VehicleEtaException] when the
  /// source cannot be reached or answers garbage.
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request);
}
