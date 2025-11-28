import 'package:latlong2/latlong.dart' as latlng;

class LatLngBounds {
  final latlng.LatLng southWest;
  final latlng.LatLng northEast;

  const LatLngBounds(this.southWest, this.northEast);
  factory LatLngBounds.fromPoints(List<latlng.LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('LatLngBounds.fromPoints requires a non-empty list');
    }
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      latlng.LatLng(minLat, minLng),
      latlng.LatLng(maxLat, maxLng),
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngBounds &&
          southWest == other.southWest &&
          northEast == other.northEast;

  @override
  int get hashCode => Object.hash(southWest, northEast);

  @override
  String toString() =>
      'LatLngBounds(sw: ${southWest.latitude},${southWest.longitude}; ne: ${northEast.latitude},${northEast.longitude})';
}
