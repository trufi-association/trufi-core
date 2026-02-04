import '../entities/itinerary.dart';

/// Generates a unique signature for an itinerary based on its transit pattern.
///
/// Itineraries with the same signature differ only in timing (departure/arrival times)
/// but use the same routes, stops, and transfer points.
///
/// The signature includes:
/// - Transport mode for each leg
/// - Route ID (gtfsId) for transit legs
/// - From/to stop IDs for transit legs
///
/// Walk legs only contribute their mode to maintain pattern matching
/// while allowing for slight variations in walking times.
String generateItinerarySignature(Itinerary itinerary) {
  final buffer = StringBuffer();

  for (final leg in itinerary.legs) {
    if (leg.transitLeg) {
      // For transit legs: mode + route ID + from stop + to stop
      final routeId = leg.route?.gtfsId ?? leg.route?.id ?? leg.shortName ?? '';
      final fromStopId = leg.fromPlace?.stopId ?? '';
      final toStopId = leg.toPlace?.stopId ?? '';
      buffer.write('T:${leg.mode}:$routeId:$fromStopId:$toStopId|');
    } else {
      // For non-transit legs (walk, bike): just the mode
      buffer.write('${leg.mode}|');
    }
  }

  return buffer.toString();
}

/// Extension on Itinerary to get the signature.
extension ItinerarySignatureExtension on Itinerary {
  /// Gets the route pattern signature for this itinerary.
  String get routeSignature => generateItinerarySignature(this);
}
