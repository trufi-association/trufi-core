import 'package:trufi_core/models/plan_entity.dart';

class CarPark {
  final String? id;
  final String? carParkId;
  final String? name;
  final int? maxCapacity;
  final int? spacesAvailable;
  final bool? realtime;
  final double? lon;
  final double? lat;

  const CarPark({
    this.id,
    this.carParkId,
    this.name,
    this.maxCapacity,
    this.spacesAvailable,
    this.realtime,
    this.lon,
    this.lat,
  });

  factory CarPark.fromJson(Map<String, dynamic> json) => CarPark(
    id: json['id'].toString(),
    carParkId: json['carParkId'].toString(),
    name: json['name'].toString(),
    maxCapacity: int.tryParse(json[['maxCapacity']].toString()) ?? 0,
    spacesAvailable: int.tryParse(json[['spacesAvailable']].toString()) ?? 0,
    realtime: json['realtime'] as bool?,
    lon: double.tryParse(json['lon'].toString()) ?? 0,
    lat: double.tryParse(json['lat'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'carParkId': carParkId,
    'name': name,
    'maxCapacity': maxCapacity,
    'spacesAvailable': spacesAvailable,
    'realtime': realtime,
    'lon': lon,
    'lat': lat,
  };

  CarParkEntity toCarParkEntity() {
    return CarParkEntity(
      id: id,
      carParkId: carParkId,
      name: name,
      maxCapacity: maxCapacity,
      spacesAvailable: spacesAvailable,
      realtime: realtime,
      lon: lon,
      lat: lat,
    );
  }
}
