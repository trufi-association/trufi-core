import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Vehicles to draw for the selected [itinerary]: those on its transit-leg
/// routes, or all [vehicles] when there is no itinerary or it has no transit
/// leg with a route id.
List<VehiclePosition> liveVehiclesForTrip(
  List<VehiclePosition> vehicles,
  routing.Itinerary? itinerary,
) {
  final routeIds = <String>{};
  for (final leg in itinerary?.legs ?? const <routing.Leg>[]) {
    if (!leg.transitLeg) continue;
    final id = leg.route?.gtfsId;
    if (id != null && id.isNotEmpty) routeIds.add(stripGtfsFeedPrefix(id));
  }
  if (routeIds.isEmpty) return vehicles;

  // Feed-agnostic matching: itinerary legs may come from a bundled-GTFS
  // planner (`1132`) while vehicles come from OTP (`1:1132`) — strict
  // equality here made every bus vanish the moment a search was active
  // in hybrid deploys (Lima pilot regression, caught by Sam).
  return vehicles
      .where(
        (v) =>
            v.routeId != null &&
            routeIds.contains(stripGtfsFeedPrefix(v.routeId!)),
      )
      .toList(growable: false);
}
