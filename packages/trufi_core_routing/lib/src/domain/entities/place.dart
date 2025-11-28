import 'package:latlong2/latlong.dart';

import 'vertex_type.dart';

/// A place in an itinerary (stop, station, etc.).
class Place {
  const Place({
    required this.name,
    required this.lat,
    required this.lon,
    this.vertexType = VertexType.normal,
    this.arrivalTime,
    this.departureTime,
    this.stopId,
    this.stopCode,
    this.platformCode,
    this.bikeRentalStationId,
  });

  final String name;
  final double lat;
  final double lon;
  final VertexType vertexType;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final String? stopId;
  final String? stopCode;
  final String? platformCode;
  final String? bikeRentalStationId;

  /// Creates a [Place] from JSON.
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      vertexType: VertexTypeExtension.fromString(json['vertexType'] as String?),
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['arrivalTime'] as int)
          : null,
      departureTime: json['departureTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['departureTime'] as int)
          : null,
      stopId: json['stopId'] as String?,
      stopCode: json['stopCode'] as String?,
      platformCode: json['platformCode'] as String?,
      bikeRentalStationId: json['bikeRentalStationId'] as String?,
    );
  }

  /// Converts this place to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      'vertexType': vertexType.name,
      'arrivalTime': arrivalTime?.millisecondsSinceEpoch,
      'departureTime': departureTime?.millisecondsSinceEpoch,
      'stopId': stopId,
      'stopCode': stopCode,
      'platformCode': platformCode,
      'bikeRentalStationId': bikeRentalStationId,
    };
  }

  /// Returns the position as [LatLng].
  LatLng get latLng => LatLng(lat, lon);

  @override
  bool operator ==(Object other) =>
      other is Place && other.lat == lat && other.lon == lon;

  @override
  int get hashCode => Object.hash(lat, lon);
}
