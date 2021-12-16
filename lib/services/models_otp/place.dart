import 'package:trufi_core/entities/plan_entity/place_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';

import 'bike_park.dart';
import 'bike_rental_station.dart';
import 'car_park.dart';
import 'enums/place/vertex_type.dart';
import 'stop.dart';
import 'vehicle_parking_with_entrance.dart';

class Place {
  final String? name;
  final VertexType? vertexType;
  final double? lat;
  final double? lon;
  final double? arrivalTime;
  final double? departureTime;
  final Stop? stop;
  final BikeRentalStation? bikeRentalStation;
  final BikePark? bikePark;
  final CarPark? carPark;
  final VehicleParkingWithEntrance? vehicleParkingWithEntrance;

  const Place({
    this.name,
    this.vertexType,
    this.lat,
    this.lon,
    this.arrivalTime,
    this.departureTime,
    this.stop,
    this.bikeRentalStation,
    this.bikePark,
    this.carPark,
    this.vehicleParkingWithEntrance,
  });

  factory Place.fromMap(Map<String, dynamic> json) => Place(
        name: json['name'] as String?,
        vertexType: getVertexTypeByString(json['vertexType'].toString()),
        lat: double.tryParse(json['lat'].toString()),
        lon: double.tryParse(json['lon'].toString()),
        arrivalTime: double.tryParse(json['arrivalTime'].toString()),
        departureTime: double.tryParse(json['departureTime'].toString()),
        stop: json['stop'] != null
            ? Stop.fromJson(json['stop'] as Map<String, dynamic>)
            : null,
        bikeRentalStation: json['bikeRentalStation'] != null
            ? BikeRentalStation.fromJson(
                json['bikeRentalStation'] as Map<String, dynamic>)
            : null,
        bikePark: json['bikePark'] != null
            ? BikePark.fromJson(json['bikePark'] as Map<String, dynamic>)
            : null,
        carPark: json['carPark'] != null
            ? CarPark.fromJson(json['carPark'] as Map<String, dynamic>)
            : null,
        vehicleParkingWithEntrance: json['vehicleParkingWithEntrance'] != null
            ? VehicleParkingWithEntrance.fromMap(
                json['vehicleParkingWithEntrance'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'vertexType': vertexType?.name,
        'lat': lat,
        'lon': lon,
        'arrivalTime': arrivalTime,
        'departureTime': departureTime,
        'stop': stop?.toJson(),
        'bikeRentalStation': bikeRentalStation?.toJson(),
        'bikePark': bikePark?.toJson(),
        'carPark': carPark?.toJson(),
        'vehicleParkingWithEntrance': vehicleParkingWithEntrance?.toMap(),
      };

  PlanLocation toPlanLocation() {
    return PlanLocation(
      name: name,
      longitude: lon,
      latitude: lat,
    );
  }

  PlaceEntity toPlaceEntity() {
    return PlaceEntity(
      name: name,
      vertexType: vertexType,
      lat: lat,
      lon: lon,
      arrivalTime: arrivalTime != null
          ? DateTime.fromMillisecondsSinceEpoch(arrivalTime!.toInt())
          : null,
      departureTime: departureTime != null
          ? DateTime.fromMillisecondsSinceEpoch(departureTime!.toInt())
          : null,
      stopEntity: stop?.toStopEntity(),
      bikeRentalStation: bikeRentalStation?.toBikeRentalStation(),
      bikeParkEntity: bikePark?.toBikeParkEntity(),
      carParkEntity: carPark?.toCarParkEntity(),
      vehicleParkingWithEntrance: vehicleParkingWithEntrance,
    );
  }
}
