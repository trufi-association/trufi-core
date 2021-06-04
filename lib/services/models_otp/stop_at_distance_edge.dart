import 'stop_at_distance.dart';

class StopAtDistanceEdge {
  final StopAtDistance node;
  final String cursor;

  const StopAtDistanceEdge({
    this.node,
    this.cursor,
  });

  factory StopAtDistanceEdge.fromJson(Map<String, dynamic> json) =>
      StopAtDistanceEdge(
        node: json['node'] != null
            ? StopAtDistance.fromJson(json['node'] as Map<String, dynamic>)
            : null,
        cursor: json['cursor'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'node': node?.toJson(),
        'cursor': cursor,
      };
}
