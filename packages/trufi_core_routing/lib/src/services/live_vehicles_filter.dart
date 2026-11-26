import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../models/itinerary.dart';
import '../models/leg.dart';
import 'realtime_vehicles_eta_provider.dart';

/// Vehicles to draw for the selected [itinerary]: those that can still
/// board the trip, or all [vehicles] when there is no itinerary or it has no
/// transit leg with a route id.
///
/// A vehicle is kept when a transit leg has its route and
/// [RealtimeVehiclesEtaProvider.headsTowards] its boarding stop, so
/// buses of the opposite direction or already past the stop are dropped.
/// The ETA rule also keeps a bus that is (nearly) stopped (below
/// `minPlausibleSpeedMps`), one within `headingIgnoredWithinMeters` of the
/// stop, and one without heading: a bus stopped just past the stop stays on
/// the map until it moves on. With 48 buses on two routes the rider could
/// not tell which one was theirs (trufi-lima#7).
///
/// The rule compares the heading with the straight-line bearing to the stop,
/// so a bus still before the stop whose road points away at that moment (a
/// corner, a one-way loop) can disappear until it turns. Measuring progress
/// along the route's shape is the follow-up (trufi-lima#7).
///
/// The "next bus" badge (#1016) uses the same heading/direction test; it
/// additionally looks at the first ride only and drops stale
/// (`defaultMaxVehicleAge`, 5 min) and far (`defaultMaxDistanceMeters`,
/// 10 km) vehicles. A transit leg without `fromPlace` matches by route only.
List<VehiclePosition> liveVehiclesForTrip(
  List<VehiclePosition> vehicles,
  Itinerary? itinerary,
) {
  final legsByRoute = <String, List<Leg>>{};
  for (final leg in itinerary?.legs ?? const <Leg>[]) {
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

bool _canBoard(VehiclePosition vehicle, Leg leg) {
  final from = leg.fromPlace;
  if (from == null) return true;
  return RealtimeVehiclesEtaProvider.headsTowards(
    vehicle,
    TrufiLatLng(from.lat, from.lon),
    leg.directionId,
  );
}
