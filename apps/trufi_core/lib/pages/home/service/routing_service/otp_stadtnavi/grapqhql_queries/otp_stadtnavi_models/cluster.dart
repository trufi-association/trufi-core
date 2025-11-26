import 'stop.dart';

class Cluster {
  final String? id;
  final String? gtfsId;
  final String? name;
  final double? lat;
  final double? lon;
  final List<Stop>? stops;

  const Cluster({
    this.id,
    this.gtfsId,
    this.name,
    this.lat,
    this.lon,
    this.stops,
  });

  factory Cluster.fromJson(Map<String, dynamic> json) => Cluster(
        id: json['id'] as String?,
        gtfsId: json['gtfsId'] as String?,
        name: json['name'] as String?,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        stops: json['stops'] != null
            ? List<Stop>.from((json["stops"] as List<dynamic>).map(
                (x) => Stop.fromJson(x as Map<String, dynamic>),
              ))
            : null,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'gtfsId': gtfsId,
        'name': name,
        'lat': lat,
        'lon': lon,
        'stops': List<dynamic>.from((stops ?? []).map((x) => x.toJson())),
      };
}
