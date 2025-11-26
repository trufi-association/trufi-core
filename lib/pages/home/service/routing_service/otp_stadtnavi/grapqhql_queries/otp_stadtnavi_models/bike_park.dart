import 'package:trufi_core/models/plan_entity.dart';

class BikePark {
  final String? id;
  final String? bikeParkId;
  final String? name;
  final int? spacesAvailable;
  final bool? realtime;
  final double? lon;
  final double? lat;

  const BikePark({
    this.id,
    this.bikeParkId,
    this.name,
    this.spacesAvailable,
    this.realtime,
    this.lon,
    this.lat,
  });

  factory BikePark.fromJson(Map<String, dynamic> json) => BikePark(
        id: json['id'] as String?,
        bikeParkId: json['bikeParkId'] as String?,
        name: json['name'] as String?,
        spacesAvailable: int.tryParse(json['spacesAvailable'].toString()),
        realtime: json['realtime'] as bool?,
        lon: double.tryParse(json['lon'].toString()),
        lat: double.tryParse(json['lat'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bikeParkId': bikeParkId,
        'name': name,
        'spacesAvailable': spacesAvailable,
        'realtime': realtime,
        'lon': lon,
        'lat': lat,
      };

  BikeParkEntity toBikeParkEntity() {
    return BikeParkEntity(
      id: id,
      bikeParkId: bikeParkId,
      name: name,
      spacesAvailable: spacesAvailable,
      realtime: realtime,
      lon: lon,
      lat: lat,
    );
  }
}
