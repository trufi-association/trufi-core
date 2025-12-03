import 'itinerary_leg.dart';
import 'transport_mode.dart';

/// A complete itinerary for a trip plan.
class Itinerary {
  Itinerary({
    required this.legs,
    required this.startTime,
    required this.endTime,
    required this.walkTime,
    required this.duration,
    required this.walkDistance,
    this.arrivedAtDestinationWithRentedBicycle = false,
    this.emissionsPerPerson,
  }) : distance = _calculateDistance(legs);

  final List<ItineraryLeg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration walkTime;
  final Duration duration;
  final double walkDistance;
  final bool arrivedAtDestinationWithRentedBicycle;
  final double? emissionsPerPerson;
  final int distance;

  static int _calculateDistance(List<ItineraryLeg> legs) {
    return legs.fold<int>(0, (sum, leg) => sum + leg.distance.ceil());
  }

  /// Creates an [Itinerary] from JSON.
  factory Itinerary.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> Function(String)? polylineDecoder,
  }) {
    return Itinerary(
      legs: (json['legs'] as List<dynamic>)
          .map((e) => ItineraryLeg.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      walkTime: Duration(seconds: json['walkTime'] as int),
      duration: Duration(seconds: json['duration'] as int),
      walkDistance: (json['walkDistance'] as num).toDouble(),
      arrivedAtDestinationWithRentedBicycle:
          json['arrivedAtDestinationWithRentedBicycle'] as bool? ?? false,
      emissionsPerPerson:
          (json['emissionsPerPerson']?['emissionsPerPersonCo2'] as num?)
              ?.toDouble(),
    );
  }

  /// Converts this itinerary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'legs': legs.map((e) => e.toJson()).toList(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'walkTime': walkTime.inSeconds,
      'duration': duration.inSeconds,
      'walkDistance': walkDistance,
      'arrivedAtDestinationWithRentedBicycle':
          arrivedAtDestinationWithRentedBicycle,
      'emissionsPerPerson': {'emissionsPerPersonCo2': emissionsPerPerson},
    };
  }

  /// Returns the first transit leg (bus, train, etc.) or null.
  ItineraryLeg? get firstTransitLeg {
    return legs.cast<ItineraryLeg?>().firstWhere(
          (leg) => leg?.transitLeg ?? false,
          orElse: () => null,
        );
  }

  /// Returns true if this itinerary is walk-only.
  bool get isWalkOnly {
    return legs.every(
      (leg) => leg.transportMode == TransportMode.walk,
    );
  }

  /// Returns all transit legs.
  List<ItineraryLeg> get transitLegs {
    return legs.where((leg) => leg.transitLeg).toList();
  }

  /// Returns the number of transfers.
  int get numberOfTransfers {
    final transit = transitLegs;
    return transit.isEmpty ? 0 : transit.length - 1;
  }
}
