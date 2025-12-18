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
  /// - Leg segments for proper rendering with colors and styles
  static NavigationRoute toNavigationRoute(routing.Itinerary itinerary) {
    // Get all points from all legs for geometry
    final allPoints = <LatLng>[];
    final navigationLegs = <NavigationLeg>[];

    for (int i = 0; i < itinerary.legs.length; i++) {
      final leg = itinerary.legs[i];
      allPoints.addAll(leg.decodedPoints);

      // Parse leg color
      int? legColor;
      if (leg.routeColor.isNotEmpty) {
        legColor = int.tryParse('FF${leg.routeColor}', radix: 16);
      }

      // Determine leg type
      final isWalking = leg.transportMode == routing.TransportMode.walk;
      final isBicycle = leg.transportMode == routing.TransportMode.bicycle;

      navigationLegs.add(NavigationLeg(
        id: 'leg-$i',
        points: leg.decodedPoints,
        isTransit: leg.transitLeg,
        isWalking: isWalking,
        isBicycle: isBicycle,
        color: legColor,
        routeName: leg.shortName ?? leg.route?.shortName,
        modeName: leg.mode,
        duration: leg.duration,
      ));
    }

    // Get first transit leg for route info
    final transitLeg = itinerary.legs.firstWhere(
      (leg) => leg.transitLeg,
      orElse: () => itinerary.legs.first,
    );

    // Create stops for the entire route:
    // 1. Origin (start of first leg)
    // 2. Transfer points between legs
    // 3. Intermediate stops from transit legs
    // 4. Destination (end of last leg)
    final stops = <NavigationStop>[];
    var stopIndex = 0;

    // Add origin from first leg's fromPlace or first point
    if (itinerary.legs.isNotEmpty) {
      final firstLeg = itinerary.legs.first;
      final fromPlace = firstLeg.fromPlace;
      if (fromPlace != null) {
        stops.add(NavigationStop(
          id: 'stop-$stopIndex',
          name: fromPlace.name.isNotEmpty ? fromPlace.name : 'Origin',
          position: LatLng(fromPlace.lat, fromPlace.lon),
        ));
        stopIndex++;
      } else if (firstLeg.decodedPoints.isNotEmpty) {
        stops.add(NavigationStop(
          id: 'stop-$stopIndex',
          name: 'Origin',
          position: firstLeg.decodedPoints.first,
        ));
        stopIndex++;
      }
    }

    // Add transfer points and intermediate stops
    for (int i = 0; i < itinerary.legs.length; i++) {
      final leg = itinerary.legs[i];

      // Add intermediate stops from transit legs
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

      // Add the end of this leg (which is the transfer point)
      // Skip if it's the last leg (we'll add destination separately)
      if (i < itinerary.legs.length - 1) {
        final toPlace = leg.toPlace;
        if (toPlace != null) {
          stops.add(NavigationStop(
            id: 'stop-$stopIndex',
            name: toPlace.name.isNotEmpty ? toPlace.name : 'Transfer',
            position: LatLng(toPlace.lat, toPlace.lon),
          ));
          stopIndex++;
        } else if (leg.decodedPoints.isNotEmpty) {
          stops.add(NavigationStop(
            id: 'stop-$stopIndex',
            name: 'Transfer',
            position: leg.decodedPoints.last,
          ));
          stopIndex++;
        }
      }
    }

    // Add destination (end of last leg)
    if (itinerary.legs.isNotEmpty) {
      final lastLeg = itinerary.legs.last;
      final toPlace = lastLeg.toPlace;
      if (toPlace != null) {
        stops.add(NavigationStop(
          id: 'stop-$stopIndex',
          name: toPlace.name.isNotEmpty ? toPlace.name : 'Destination',
          position: LatLng(toPlace.lat, toPlace.lon),
        ));
      } else if (lastLeg.decodedPoints.isNotEmpty) {
        stops.add(NavigationStop(
          id: 'stop-$stopIndex',
          name: 'Destination',
          position: lastLeg.decodedPoints.last,
        ));
      }
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
      legs: navigationLegs,
    );
  }
}
