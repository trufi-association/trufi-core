import 'page_info.dart';
import 'place_at_distance_edge.dart';

class PlaceAtDistanceConnection {
  final List<PlaceAtDistanceEdge> edges;
  final PageInfo pageInfo;

  const PlaceAtDistanceConnection({this.edges, this.pageInfo});

  factory PlaceAtDistanceConnection.fromJson(Map<String, dynamic> json) =>
      PlaceAtDistanceConnection(
        edges: json['edges'] != null
            ? List<PlaceAtDistanceEdge>.from(
                (json["edges"] as List<dynamic>).map(
                (x) => PlaceAtDistanceEdge.fromJson(x as Map<String, dynamic>),
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
