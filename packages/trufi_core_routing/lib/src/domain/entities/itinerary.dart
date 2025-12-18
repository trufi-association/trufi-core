import 'package:equatable/equatable.dart';

import 'leg.dart';
import 'route.dart';
import 'transport_mode.dart';

/// A complete itinerary for a trip plan.
class Itinerary extends Equatable {
  Itinerary({
    required List<Leg> legs,
    required this.startTime,
    required this.endTime,
    required this.walkTime,
    required this.duration,
    required this.walkDistance,
    this.transfers,
    this.arrivedAtDestinationWithRentedBicycle = false,
    this.emissionsPerPerson,
  })  : legs = _assignDefaultColors(legs),
        distance = _calculateDistance(legs);

  final List<Leg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration walkTime;
  final Duration duration;
  final double walkDistance;
  final int? transfers;
  final bool arrivedAtDestinationWithRentedBicycle;
  final double? emissionsPerPerson;
  final int distance;

  static int _calculateDistance(List<Leg> legs) {
    return legs.fold<int>(0, (sum, leg) => sum + leg.distance.ceil());
  }

  // Default colors for transit legs without route color
  static const _defaultTransitColors = ['1976D2', 'E91E63', '4CAF50', 'FF9800'];

  /// Creates an [Itinerary] from JSON.
  factory Itinerary.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> Function(String)? polylineDecoder,
  }) {
    final parsedLegs = (json['legs'] as List<dynamic>)
        .map((e) => Leg.fromJson(e as Map<String, dynamic>))
        .toList();

    // Colors are now assigned in the constructor
    return Itinerary(
      legs: parsedLegs,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      walkTime: Duration(seconds: json['walkTime'] as int),
      duration: Duration(seconds: json['duration'] as int),
      walkDistance: (json['walkDistance'] as num).toDouble(),
      transfers: json['transfers'] as int?,
      arrivedAtDestinationWithRentedBicycle:
          json['arrivedAtDestinationWithRentedBicycle'] as bool? ?? false,
      emissionsPerPerson:
          (json['emissionsPerPerson']?['emissionsPerPersonCo2'] as num?)
              ?.toDouble(),
    );
  }

  static List<Leg> _assignDefaultColors(List<Leg> legs) {
    int transitIndex = 0;
    return legs.map((leg) {
      if (leg.transitLeg && (leg.route?.color == null || leg.route!.color!.isEmpty)) {
        final defaultColor = _defaultTransitColors[transitIndex % _defaultTransitColors.length];
        transitIndex++;
        return leg.copyWith(
          route: leg.route?.copyWith(color: defaultColor) ??
                 Route(color: defaultColor, shortName: leg.shortName),
        );
      }
      if (leg.transitLeg) transitIndex++;
      return leg;
    }).toList();
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
      'transfers': transfers,
      'arrivedAtDestinationWithRentedBicycle':
          arrivedAtDestinationWithRentedBicycle,
      'emissionsPerPerson': {'emissionsPerPersonCo2': emissionsPerPerson},
    };
  }

  /// Creates a copy of this itinerary with the given fields replaced.
  Itinerary copyWith({
    List<Leg>? legs,
    DateTime? startTime,
    DateTime? endTime,
    Duration? walkTime,
    Duration? duration,
    double? walkDistance,
    int? transfers,
    bool? arrivedAtDestinationWithRentedBicycle,
    double? emissionsPerPerson,
  }) {
    return Itinerary(
      legs: legs ?? this.legs,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      walkTime: walkTime ?? this.walkTime,
      duration: duration ?? this.duration,
      walkDistance: walkDistance ?? this.walkDistance,
      transfers: transfers ?? this.transfers,
      arrivedAtDestinationWithRentedBicycle:
          arrivedAtDestinationWithRentedBicycle ??
              this.arrivedAtDestinationWithRentedBicycle,
      emissionsPerPerson: emissionsPerPerson ?? this.emissionsPerPerson,
    );
  }

  /// Returns the first transit leg (bus, train, etc.) or null.
  Leg? get firstTransitLeg {
    return legs.cast<Leg?>().firstWhere(
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
  List<Leg> get transitLegs {
    return legs.where((leg) => leg.transitLeg).toList();
  }

  /// Returns the number of transfers (from JSON or calculated).
  int get numberOfTransfers {
    if (transfers != null) return transfers!;
    final transit = transitLegs;
    return transit.isEmpty ? 0 : transit.length - 1;
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        duration,
        walkTime,
        walkDistance,
        transfers,
        arrivedAtDestinationWithRentedBicycle,
        emissionsPerPerson,
        distance,
        legs,
      ];
}
