import 'stop.dart';

class StopAtDistance {
  final String? id;
  final Stop? stop;
  final int? distance;

  const StopAtDistance({
    this.id,
    this.stop,
    this.distance,
  });

  factory StopAtDistance.fromJson(Map<String, dynamic> json) => StopAtDistance(
        id: json['id'].toString(),
        stop: json['stop'] != null
            ? Stop.fromJson(json['stop'] as Map<String, dynamic>)
            : null,
        distance: int.tryParse(json['distance'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stop': stop?.toJson(),
        'distance': distance,
      };
}
