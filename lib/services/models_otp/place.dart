import 'bike_park.dart';
import 'bike_rental_station.dart';
import 'car_park.dart';
import 'enums/place/vertex_type.dart';
import 'stop.dart';

class Place {
  final String name;
  final VertexType vertexType;
  final double lat;
  final double lon;
  final double arrivalTime;
  final double departureTime;
  final Stop stop;
  final BikeRentalStation bikeRentalStation;
  final BikePark bikePark;
  final CarPark carPark;

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
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        name: json['name'].toString(),
        vertexType: getVertexTypeByString(json['vertexType'].toString()),
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        arrivalTime: double.tryParse(json['arrivalTime'].toString()) ?? 0,
        departureTime: double.tryParse(json['departureTime'].toString()) ?? 0,
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
      );

  Map<String, dynamic> toJson() => {
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
      };
}
