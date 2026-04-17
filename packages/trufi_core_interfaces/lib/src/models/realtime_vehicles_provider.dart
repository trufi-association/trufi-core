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

/// Convenience queries computed on top of [RealtimeVehiclesProvider.latest].
extension RealtimeVehiclesProviderQueries on RealtimeVehiclesProvider {
  List<VehiclePosition> vehiclesForRoute(String routeGtfsId) => latest
      .where((v) => v.routeId == routeGtfsId)
      .toList(growable: false);

  List<VehiclePosition> vehiclesForRoutes(Set<String> routeGtfsIds) => latest
      .where((v) => v.routeId != null && routeGtfsIds.contains(v.routeId))
      .toList(growable: false);

  bool hasDataForRoute(String routeGtfsId) =>
      latest.any((v) => v.routeId == routeGtfsId);
}
