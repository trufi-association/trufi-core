import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Vehicles to draw for the selected [itinerary]: those that can still
/// board the trip, or all [vehicles] when there is no itinerary or it has no
/// transit leg with a route id.
///
/// A vehicle is kept when a transit leg has its route and
/// [routing.RealtimeVehiclesEtaProvider.headsTowards] its boarding stop, so
/// buses of the opposite direction or already past the stop are dropped.
/// The ETA rule also keeps a bus that is (nearly) stopped (below
/// `minPlausibleSpeedMps`), one within `headingIgnoredWithinMeters` of the
/// stop, and one without heading: a bus stopped just past the stop stays on
/// the map until it moves on. With 48 buses on two routes the rider could
/// not tell which one was theirs (trufi-lima#7). It reuses the ETA rule
/// (#1016) so the map and the "next bus" badge agree. A transit leg without
/// `fromPlace` matches by route only.
List<VehiclePosition> liveVehiclesForTrip(
  List<VehiclePosition> vehicles,
  routing.Itinerary? itinerary,
) {
  final legsByRoute = <String, List<routing.Leg>>{};
  for (final leg in itinerary?.legs ?? const <routing.Leg>[]) {
    if (!leg.transitLeg) continue;
    final id = leg.route?.gtfsId;
    if (id != null && id.isNotEmpty) {
      legsByRoute.putIfAbsent(stripGtfsFeedPrefix(id), () => []).add(leg);
    }
  }
  if (legsByRoute.isEmpty) return vehicles;

  // Feed-agnostic matching: itinerary legs may come from a bundled-GTFS
  // planner (`1132`) while vehicles come from OTP (`1:1132`) — strict
  // equality here made every bus vanish the moment a search was active
  // in hybrid deploys (Lima pilot regression, caught by Sam).
  return vehicles
      .where((v) {
        final legs = legsByRoute[stripGtfsFeedPrefix(v.routeId ?? '')];
        return legs != null && legs.any((leg) => _canBoard(v, leg));
      })
      .toList(growable: false);
}

bool _canBoard(VehiclePosition vehicle, routing.Leg leg) {
  final from = leg.fromPlace;
  if (from == null) return true;
  return routing.RealtimeVehiclesEtaProvider.headsTowards(
    vehicle,
    TrufiLatLng(from.lat, from.lon),
    leg.directionId,
  );
}
