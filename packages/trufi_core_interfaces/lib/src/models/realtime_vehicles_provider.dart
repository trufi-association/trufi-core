import 'vehicle_position.dart';

/// Contract for any source of live vehicle positions (GTFS-Realtime via OTP,
/// direct GTFS-RT, SIRI, custom, etc.).
///
/// This interface is intentionally minimal — just enough for UIs to subscribe
/// to updates and query the current snapshot. Convenience queries like
/// "vehicles for a given route" live in the [RealtimeVehiclesProviderQueries]
/// extension below so the contract stays small.
abstract class RealtimeVehiclesProvider {
  /// Stream of vehicle position snapshots. Emits the full current fleet on
  /// every tick.
  Stream<List<VehiclePosition>> get positionsStream;

  /// Latest snapshot (may be empty before the first tick or after [stop]).
  List<VehiclePosition> get latest;

  /// Start polling / subscribing. Idempotent.
  Future<void> start();

  /// Stop polling. Idempotent. The latest snapshot stays available.
  void stop();
}

/// Strips the OTP feed prefix (`<feedId>:<id>`) from a GTFS id.
///
/// Different sources disagree on the prefix: OTP's GraphQL emits `1:1132`
/// while a bundled-GTFS planner emits plain `1132` for the same route, so
/// any realtime-vs-itinerary route matching must be feed-agnostic or a
/// hybrid deploy (local routing + OTP vehicles, like the Lima pilot)
/// silently matches nothing. Within one deploy all feeds belong to one
/// city, so bare-id collisions across feeds are not a practical concern.
String stripGtfsFeedPrefix(String gtfsId) {
  final colon = gtfsId.indexOf(':');
  return colon >= 0 ? gtfsId.substring(colon + 1) : gtfsId;
}

/// Convenience queries computed on top of [RealtimeVehiclesProvider.latest].
/// All route matching is feed-prefix agnostic — see [stripGtfsFeedPrefix].
extension RealtimeVehiclesProviderQueries on RealtimeVehiclesProvider {
  List<VehiclePosition> vehiclesForRoute(String routeGtfsId) {
    final want = stripGtfsFeedPrefix(routeGtfsId);
    return latest
        .where(
          (v) => v.routeId != null && stripGtfsFeedPrefix(v.routeId!) == want,
        )
        .toList(growable: false);
  }

  List<VehiclePosition> vehiclesForRoutes(Set<String> routeGtfsIds) {
    final want = routeGtfsIds.map(stripGtfsFeedPrefix).toSet();
    return latest
        .where(
          (v) =>
              v.routeId != null &&
              want.contains(stripGtfsFeedPrefix(v.routeId!)),
        )
        .toList(growable: false);
  }

  bool hasDataForRoute(String routeGtfsId) {
    final want = stripGtfsFeedPrefix(routeGtfsId);
    return latest.any(
      (v) => v.routeId != null && stripGtfsFeedPrefix(v.routeId!) == want,
    );
  }
}
