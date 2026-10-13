import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

/// Reduces [itinerary] to what a saved route card shows (#1005): one badge
/// per transit leg (short name and route colour), total distance and
/// duration. The only place that knows both the routing model and the saved
/// routes model.
SavedRouteSnapshot savedRouteSnapshotFromItinerary(
  routing.Itinerary itinerary,
) {
  return SavedRouteSnapshot(
    transitLegs: [
      for (final leg in itinerary.transitLegs)
        SavedRouteTransitLeg(
          shortName: leg.displayName,
          colorHex: leg.routeColor.isEmpty ? null : leg.routeColor,
        ),
    ],
    distanceMeters: itinerary.distance,
    durationSeconds: itinerary.duration.inSeconds,
  );
}
