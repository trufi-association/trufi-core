import 'dart:convert';

import 'package:trufi_core/entities/plan_entity/bike_park_entity.dart';
import 'package:trufi_core/entities/plan_entity/stop_entity.dart';
import 'package:trufi_core/services/models_otp/enums/place/vertex_type.dart';

import 'bike_rental_station_entity.dart';
import 'car_park_entity.dart';

class PlaceEntity {
  static const _name = 'name';
  static const _vertexType = 'vertexType';
  static const _lat = 'lat';
  static const _lon = 'lon';
  static const _arrivalTime = 'arrivalTime';
  static const _departureTime = 'departureTime';
  static const _stopEntity = 'stop';
  static const _bikeRentalStation = 'bikeRentalStation';
  static const _bikeParkEntity = 'bikeParkEntity';
  static const _carParkEntity = 'carParkEntity';

  final String name;
  final VertexType vertexType;
  final double lat;
  final double lon;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final StopEntity stopEntity;
  final BikeRentalStationEntity bikeRentalStation;
  final BikeParkEntity bikeParkEntity;
  final CarParkEntity carParkEntity;

  PlaceEntity({
    this.name,
    this.vertexType,
    this.lat,
    this.lon,
    this.arrivalTime,
    this.departureTime,
    this.stopEntity,
    this.bikeRentalStation,
    this.bikeParkEntity,
    this.carParkEntity,
  });

  Map<String, dynamic> toMap() {
    return {
      _name: name,
      _vertexType: vertexType.name,
      _lat: lat,
      _lon: lon,
      _arrivalTime: arrivalTime?.millisecondsSinceEpoch,
      _departureTime: departureTime?.millisecondsSinceEpoch,
      _stopEntity: stopEntity?.toMap(),
      _bikeRentalStation: bikeRentalStation?.toMap(),
      _bikeParkEntity: bikeParkEntity?.toMap(),
      _carParkEntity: carParkEntity?.toMap(),
    };
  }

  factory PlaceEntity.fromMap(Map<String, dynamic> map) {
    return PlaceEntity(
      name: map[_name] as String,
      vertexType: getVertexTypeByString(map[_vertexType] as String),
      lat: map[_lat] as double,
      lon: map[_lon] as double,
      arrivalTime: map[_arrivalTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[_arrivalTime] as int)
          : null,
      departureTime: map[_departureTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[_departureTime] as int)
          : null,
      stopEntity: map[_stopEntity] != null
          ? StopEntity.fromMap(map[_stopEntity] as Map<String, dynamic>)
          : null,
      bikeRentalStation: map[_bikeRentalStation] != null
          ? BikeRentalStationEntity.fromMap(
              map[_bikeRentalStation] as Map<String, dynamic>)
          : null,
      bikeParkEntity: map[_bikeParkEntity] != null
          ? BikeParkEntity.fromMap(map[_bikeParkEntity] as Map<String, dynamic>)
          : null,
      carParkEntity: map[_carParkEntity] != null
          ? CarParkEntity.fromMap(map[_carParkEntity] as Map<String, dynamic>)
          : null,
    );
  }

  PlaceEntity copyWith({
    String name,
    VertexType vertexType,
    double lat,
    double lon,
    DateTime arrivalTime,
    DateTime departureTime,
    StopEntity stopEntity,
    BikeRentalStationEntity bikeRentalStation,
    BikeParkEntity bikeParkEntity,
    CarParkEntity carParkEntity,
  }) {
    return PlaceEntity(
      name: name ?? this.name,
      vertexType: vertexType ?? this.vertexType,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      stopEntity: stopEntity ?? this.stopEntity,
      bikeRentalStation: bikeRentalStation ?? this.bikeRentalStation,
      bikeParkEntity: bikeParkEntity ?? this.bikeParkEntity,
      carParkEntity: carParkEntity ?? this.carParkEntity,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaceEntity.fromJson(String source) =>
      PlaceEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
