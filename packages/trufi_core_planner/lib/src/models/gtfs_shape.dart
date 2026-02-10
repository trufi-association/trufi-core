import 'package:latlong2/latlong.dart';

/// GTFS Shape point entity.
/// Represents a shape point from shapes.txt
class GtfsShapePoint {
  final String shapeId;
  final double lat;
  final double lon;
  final int sequence;
  final double? distTraveled;

  const GtfsShapePoint({
    required this.shapeId,
    required this.lat,
    required this.lon,
    required this.sequence,
    this.distTraveled,
  });

  LatLng get position => LatLng(lat, lon);

  factory GtfsShapePoint.fromCsv(Map<String, String> row) {
    return GtfsShapePoint(
      shapeId: row['shape_id'] ?? '',
      lat: double.tryParse(row['shape_pt_lat'] ?? '') ?? 0,
      lon: double.tryParse(row['shape_pt_lon'] ?? '') ?? 0,
      sequence: int.tryParse(row['shape_pt_sequence'] ?? '') ?? 0,
      distTraveled: double.tryParse(row['shape_dist_traveled'] ?? ''),
    );
  }
}

/// A complete shape (list of points).
class GtfsShape {
  final String id;
  final List<GtfsShapePoint> points;

  const GtfsShape({
    required this.id,
    required this.points,
  });

  /// Get the shape as a list of LatLng points.
  List<LatLng> get polyline => points.map((p) => p.position).toList();

  /// Total distance of the shape (if available).
  double? get totalDistance {
    if (points.isEmpty) return null;
    return points.last.distTraveled;
  }
}
