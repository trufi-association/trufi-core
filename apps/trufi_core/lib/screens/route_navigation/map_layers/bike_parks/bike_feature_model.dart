import 'package:latlong2/latlong.dart';
import 'package:vector_tile/vector_tile.dart';

enum BikeParkLayerIds { covered, notCovered }

class BikeParkFeature {
  final GeoJsonPoint? geoJsonPoint;
  final String id;
  final String? name;
  final String? state;
  final String? tags;
  final bool? bicyclePlaces;
  final bool? anyCarPlaces;
  final bool? carPlaces;
  final bool? wheelchairAccessibleCarPlaces;
  final bool? realTimeData;
  final String? capacity;
  final int? bicyclePlacesCapacity;
  final BikeParkLayerIds? type;
  final LatLng position;

  BikeParkFeature({
    this.geoJsonPoint,
    required this.id,
    this.name,
    this.state,
    this.tags,
    this.bicyclePlaces,
    this.anyCarPlaces,
    this.carPlaces,
    this.wheelchairAccessibleCarPlaces,
    this.realTimeData,
    this.capacity,
    this.bicyclePlacesCapacity,
    this.type,
    required this.position,
  });
  
  static BikeParkFeature? fromGeoJsonPoint(GeoJsonPoint? geoJsonPoint) {
    String? id;
    String? name;
    String? state;
    String? tags;
    bool? bicyclePlaces;
    bool? anyCarPlaces;
    bool? carPlaces;
    bool? wheelchairAccessibleCarPlaces;
    bool? realTimeData;
    String? capacity;
    int? bicyclePlacesCapacity;
    BikeParkLayerIds? type;
    if (geoJsonPoint?.properties == null) return null;
    final properties = geoJsonPoint?.properties;
    id = properties?['id']?.dartStringValue;
    name = properties?['name']?.dartStringValue;
    state = properties?['state']?.dartStringValue;
    bicyclePlaces = properties?['bicyclePlaces']?.dartBoolValue;
    anyCarPlaces = properties?['anyCarPlaces']?.dartBoolValue;
    carPlaces = properties?['carPlaces']?.dartBoolValue;
    wheelchairAccessibleCarPlaces =
        properties?['wheelchairAccessibleCarPlaces']?.dartBoolValue;
    realTimeData = properties?['realTimeData']?.dartBoolValue;
    capacity = properties?['capacity']?.dartStringValue;
    bicyclePlacesCapacity = properties?['capacity.bicyclePlaces']?.dartIntValue
        ?.toInt();
    tags = properties?['tags']?.dartStringValue;
    type = tags != null
        ? tags.contains("osm:covered")
              ? BikeParkLayerIds.covered
              : BikeParkLayerIds.notCovered
        : null;
    if (type == null || bicyclePlaces == null || !bicyclePlaces) return null;
    return BikeParkFeature(
      geoJsonPoint: geoJsonPoint,
      id: id ?? '',
      name: name,
      state: state,
      tags: tags,
      bicyclePlaces: bicyclePlaces,
      anyCarPlaces: anyCarPlaces,
      carPlaces: carPlaces,
      wheelchairAccessibleCarPlaces: wheelchairAccessibleCarPlaces,
      realTimeData: realTimeData,
      capacity: capacity,
      bicyclePlacesCapacity: bicyclePlacesCapacity,
      type: type,
      position: LatLng(
        geoJsonPoint?.geometry?.coordinates[1] ?? 0,
        geoJsonPoint?.geometry?.coordinates[0] ?? 0,
      ),
    );
  }
}
