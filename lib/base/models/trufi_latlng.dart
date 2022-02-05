import 'package:equatable/equatable.dart';

class TrufiLatLng extends Equatable {
  final double latitude;
  final double longitude;

  const TrufiLatLng({
    required this.latitude,
    required this.longitude,
  });

  factory TrufiLatLng.fromJson(Map<String, dynamic> json) {
    return TrufiLatLng(
      latitude: json["latitude"] as double,
      longitude: json["longitude"] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
