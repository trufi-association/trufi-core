import 'page_info.dart';
import 'stop_at_distance_edge.dart';

class StopAtDistanceConnection {
  final List<StopAtDistanceEdge> edges;
  final PageInfo pageInfo;

  const StopAtDistanceConnection({
    this.edges,
    this.pageInfo,
  });

  factory StopAtDistanceConnection.fromJson(Map<String, dynamic> json) =>
      StopAtDistanceConnection(
        edges: json['edges'] != null
            ? List<StopAtDistanceEdge>.from(
                (json["edges"] as List<dynamic>).map(
                (x) => StopAtDistanceEdge.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        pageInfo: json['pageInfo'] != null
            ? PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'edges':
            List.generate(edges?.length ?? 0, (index) => edges[index].toJson()),
        'pageInfo': pageInfo?.toJson(),
      };
}
