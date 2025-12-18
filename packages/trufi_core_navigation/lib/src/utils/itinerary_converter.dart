import 'package:latlong2/latlong.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import '../models/navigation_state.dart';

/// Converts a routing Itinerary to a NavigationRoute.
///
/// This utility extracts the necessary information from an OTP itinerary
/// to create a navigation route with stops and geometry.
class ItineraryConverter {
  /// Converts an [Itinerary] to a [NavigationRoute].
  ///
  /// The conversion extracts:
  /// - All geometry points from all legs
  /// - Transit leg information (route name, color, short name)
  /// - Intermediate stops from transit legs
  static NavigationRoute toNavigationRoute(routing.Itinerary itinerary) {
    // Get all points from all legs for geometry
    final allPoints = <LatLng>[];
    for (final leg in itinerary.legs) {
      allPoints.addAll(leg.decodedPoints);
    }

    // Get first transit leg for route info
    final transitLeg = itinerary.legs.firstWhere(
      (leg) => leg.transitLeg,
      orElse: () => itinerary.legs.first,
    );

    // Create stops from transit legs
    final stops = <NavigationStop>[];
    var stopIndex = 0;

    for (final leg in itinerary.legs) {
      if (leg.transitLeg && leg.intermediatePlaces != null) {
        for (final place in leg.intermediatePlaces!) {
          stops.add(NavigationStop(
            id: 'stop-$stopIndex',
            name: place.name,
            position: LatLng(place.lat, place.lon),
          ));
          stopIndex++;
        }
      }
    }

    // If no stops found, add origin and destination
    if (stops.isEmpty && allPoints.isNotEmpty) {
      stops.add(NavigationStop(
        id: 'origin',
        name: 'Origin',
        position: allPoints.first,
      ));
      stops.add(NavigationStop(
        id: 'destination',
        name: 'Destination',
        position: allPoints.last,
      ));
    }

    // Parse route color
    int? backgroundColor;
    if (transitLeg.routeColor.isNotEmpty) {
      backgroundColor = int.tryParse('FF${transitLeg.routeColor}', radix: 16);
    }

    return NavigationRoute(
      id: 'route-${DateTime.now().millisecondsSinceEpoch}',
      code: transitLeg.shortName ?? 'ROUTE',
      name: transitLeg.route?.longName ?? transitLeg.shortName ?? 'Route',
      shortName: transitLeg.shortName,
      backgroundColor: backgroundColor,
      geometry: allPoints,
      stops: stops,
    );
  }
}
