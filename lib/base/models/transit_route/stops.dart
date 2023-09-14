import 'package:equatable/equatable.dart';

class Stop extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const Stop({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        name: json['name'] as String,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };

  @override
  List<Object?> get props => [
        name,
        lat,
        lon,
      ];
}
