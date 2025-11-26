import 'package:trufi_core/models/vehicle_places.dart';

class VehicleParkingEntity {
  final String? name;
  final double? lat;
  final double? lon;
  final VehiclePlacesEntity? capacity;
  final VehiclePlacesEntity? availability;
  final String? imageUrl;
  final List<String>? tags;
  final bool? anyCarPlaces;
  final String? vehicleParkingId;
  final String? detailsUrl;
  final String? note;
  final String? openingHours;

  const VehicleParkingEntity({
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

  static const String _name = 'name';
  static const String _lat = 'lat';
  static const String _lon = 'lon';
  static const String _capacity = 'capacity';
  static const String _availability = 'availability';
  static const String _imageUrl = 'imageUrl';
  static const String _tags = 'tags';
  static const String _anyCarPlaces = 'anyCarPlaces';
  static const String _vehicleParkingId = 'vehicleParkingId';
  static const String _detailsUrl = 'detailsUrl';
  static const String _note = 'note';
  static const String _openingHours = 'openingHours';
  static const String _osm = 'osm';

  factory VehicleParkingEntity.fromMap(Map<String, dynamic> json) => VehicleParkingEntity(
    name: json[_name],
    lat: json[_lat],
    lon: json[_lon],
    capacity:
        json[_capacity] != null
            ? VehiclePlacesEntity.fromMap(json[_capacity] as Map<String, dynamic>)
            : null,
    availability:
        json[_availability] != null
            ? VehiclePlacesEntity.fromMap(json[_availability] as Map<String, dynamic>)
            : null,
    imageUrl: json[_imageUrl],
    tags:
        json[_tags] != null
            ? (json[_tags] as List<dynamic>).cast<String>()
            : null,
    anyCarPlaces: json[_anyCarPlaces],
    vehicleParkingId: json[_vehicleParkingId],
    detailsUrl: json[_detailsUrl],
    note: json[_note],
    openingHours: json[_openingHours]?[_osm],
  );

  Map<String, dynamic> toMap() => {
    _name: name,
    _lat: lat,
    _lon: lon,
    _capacity: capacity?.toMap(),
    _availability: availability?.toMap(),
    _imageUrl: imageUrl,
    _tags: tags,
    _anyCarPlaces: anyCarPlaces,
    _vehicleParkingId: vehicleParkingId,
    _detailsUrl: detailsUrl,
    _note: note,
    _openingHours: {_osm: openingHours},
  };
}
