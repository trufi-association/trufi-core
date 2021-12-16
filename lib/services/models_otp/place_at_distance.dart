import 'place_interface.dart';

class PlaceAtDistance {
  final String? id;
  final PlaceInterface? place;
  final int? distance;

  const PlaceAtDistance({this.id, this.place, this.distance});

  factory PlaceAtDistance.fromJson(Map<String, dynamic> json) =>
      PlaceAtDistance(
        id: json['id'].toString(),
        place: json['place'] != null
            ? PlaceInterface.fromJson(json['place'] as Map<String, dynamic>)
            : null,
        distance: int.tryParse(json['distance'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'place': place?.toJson(),
        'distance': distance,
      };
}
