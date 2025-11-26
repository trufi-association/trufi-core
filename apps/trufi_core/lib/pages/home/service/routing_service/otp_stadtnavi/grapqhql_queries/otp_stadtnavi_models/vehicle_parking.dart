import 'package:trufi_core/models/vehicle_parking.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/otp_stadtnavi_models/vehicle_places.dart';

class VehicleParking {
  final String? name;
  final double? lat;
  final double? lon;
  final VehiclePlaces? capacity;
  final VehiclePlaces? availability;
  final String? imageUrl;
  final List<String>? tags;
  final bool? anyCarPlaces;
  final String? vehicleParkingId;
  final String? detailsUrl;
  final String? note;
  final String? openingHours;

  const VehicleParking({
    this.name,
    this.lat,
    this.lon,
    this.capacity,
    this.availability,
    this.imageUrl,
    this.tags,
    this.anyCarPlaces,
    this.vehicleParkingId,
    this.detailsUrl,
    this.note,
    this.openingHours,
  });

  factory VehicleParking.fromMap(Map<String, dynamic> json) => VehicleParking(
    name: json['name'] as String?,
    lat: double.tryParse(json['lat'].toString()),
    lon: double.tryParse(json['lon'].toString()),
    capacity: json['capacity'] != null
        ? VehiclePlaces.fromMap(json['capacity'] as Map<String, dynamic>)
        : null,
    availability: json['availability'] != null
        ? VehiclePlaces.fromMap(json['availability'] as Map<String, dynamic>)
        : null,
    imageUrl: json['imageUrl'] as String?,
    tags: json['tags'] != null
        ? (json['tags'] as List<dynamic>).cast<String>()
        : null,
    anyCarPlaces: json['anyCarPlaces'] as bool?,
    vehicleParkingId: json['vehicleParkingId'] as String?,
    detailsUrl: json['detailsUrl'] as String?,
    note: json['note'] as String?,
    openingHours: json['openingHours']?['osm'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'lat': lat,
    'lon': lon,
    'capacity': capacity?.toMap(),
    'availability': availability?.toMap(),
    'imageUrl': imageUrl,
    'tags': tags,
    'anyCarPlaces': anyCarPlaces,
    'vehicleParkingId': vehicleParkingId,
    'detailsUrl': detailsUrl,
    'note': note,
    'openingHours': {'osm': openingHours},
  };

  VehicleParkingEntity toVehicleParkingEntity() {
    return VehicleParkingEntity(
      name: name,
      lat: lat,
      lon: lon,
      capacity: capacity?.toVehiclePlacesEntity(),
      availability: availability?.toVehiclePlacesEntity(),
      imageUrl: imageUrl,
      tags: tags,
      anyCarPlaces: anyCarPlaces,
      vehicleParkingId: vehicleParkingId,
      detailsUrl: detailsUrl,
      note: note,
      openingHours: openingHours,
    );
  }
}
