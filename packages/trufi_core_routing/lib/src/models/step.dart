import 'package:latlong2/latlong.dart';

/// A walking step in an itinerary leg.
class Step {
  const Step({
    this.distance,
    this.relativeDirection,
    this.streetName,
    this.absoluteDirection,
    this.stayOn,
    this.area,
    this.exit,
    this.lat,
    this.lon,
  });

  final double? distance;
  final String? relativeDirection;
  final String? streetName;
  final String? absoluteDirection;
  final bool? stayOn;
  final bool? area;
  final String? exit;
  final double? lat;
  final double? lon;

  /// Creates a [Step] from JSON.
  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      distance: (json['distance'] as num?)?.toDouble(),
      relativeDirection: json['relativeDirection'] as String?,
      streetName: json['streetName'] as String?,
      absoluteDirection: json['absoluteDirection'] as String?,
      stayOn: json['stayOn'] as bool?,
      area: json['area'] as bool?,
      exit: json['exit'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }

  /// Converts this step to JSON.
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'relativeDirection': relativeDirection,
      'streetName': streetName,
      'absoluteDirection': absoluteDirection,
      'stayOn': stayOn,
      'area': area,
      'exit': exit,
      'lat': lat,
      'lon': lon,
    };
  }

  /// Returns the position as [LatLng] if available.
  LatLng? get latLng {
    if (lat != null && lon != null) {
      return LatLng(lat!, lon!);
    }
    return null;
  }
}
