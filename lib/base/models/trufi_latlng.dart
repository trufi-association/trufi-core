import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class TrufiLatLng extends Equatable {
  final double latitude;
  final double longitude;

  const TrufiLatLng({
    required this.latitude,
    required this.longitude,
  });

  factory TrufiLatLng.fromLatLng(LatLng latLng) {
    return TrufiLatLng(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }
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

  LatLng toLatLng() => LatLng(latitude, longitude);

  static List<LatLng> toListLatLng(List<TrufiLatLng> listTrufiLatLng) {
    return listTrufiLatLng.map((e) => e.toLatLng()).toList();
  }

  static List<TrufiLatLng> fromListLatLng(List<LatLng> listTrufiLatLng) {
    return listTrufiLatLng.map((e) => TrufiLatLng.fromLatLng(e)).toList();
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
