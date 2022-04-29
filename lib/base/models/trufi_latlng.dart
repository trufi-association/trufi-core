import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

class TrufiLatLng extends Equatable {
  final double latitude;
  final double longitude;

  const TrufiLatLng(
    this.latitude,
    this.longitude,
  );

  factory TrufiLatLng.fromLatLng(LatLng latLng) {
    return TrufiLatLng(
      latLng.latitude,
      latLng.longitude,
    );
  }

  factory TrufiLatLng.fromGoogleLatLng(google.LatLng latLng) {
    return TrufiLatLng(
      latLng.latitude,
      latLng.longitude,
    );
  }

  factory TrufiLatLng.fromJson(Map<String, dynamic> json) {
    return TrufiLatLng(
      json["latitude"] as double,
      json["longitude"] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  google.LatLng toGoogleLatLng() => google.LatLng(latitude, longitude);

  static List<LatLng> toListLatLng(List<TrufiLatLng> listTrufiLatLng) {
    return listTrufiLatLng.map((e) => e.toLatLng()).toList();
  }

  static List<TrufiLatLng> fromListLatLng(List<LatLng> listTrufiLatLng) {
    return listTrufiLatLng.map((e) => TrufiLatLng.fromLatLng(e)).toList();
  }

  static List<google.LatLng> fromGoogleListLatLng(
      List<TrufiLatLng> listTrufiLatLng) {
    return listTrufiLatLng.map((e) => e.toGoogleLatLng()).toList();
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
