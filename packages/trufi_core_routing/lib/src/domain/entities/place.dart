import 'package:latlong2/latlong.dart';

import '../../data/utils/json_utils.dart';
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
      lat: json.getDoubleOr('lat', 0),
      lon: json.getDoubleOr('lon', 0),
      vertexType: VertexTypeExtension.fromString(json['vertexType'] as String?),
      arrivalTime: json.getDateTime('arrivalTime'),
      departureTime: json.getDateTime('departureTime'),
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
