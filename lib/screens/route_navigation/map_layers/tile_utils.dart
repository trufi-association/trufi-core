import 'dart:math' as math;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class TileRange {
  final int minX, maxX, minY, maxY;
  const TileRange({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });
}

class TileCoord {
  final int x, y, z;
  const TileCoord(this.x, this.y, this.z);
  String get key => '$z/$x/$y';
}

class TileUtils {
  static math.Point<int> latLonToTileXY(double lat, double lon, int z) {
    final latRad = lat * math.pi / 180.0;
    final n = math.pow(2.0, z).toDouble();
    final x = ((lon + 180.0) / 360.0) * n;
    final y =
        ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
            2.0) *
        n;
    return math.Point(x.floor(), y.floor());
  }

  static double tile2lon(int x, int z) {
    final n = math.pow(2.0, z).toDouble();
    return x / n * 360.0 - 180.0;
  }

  static double tile2lat(int y, int z) {
    final n = math.pow(2.0, z).toDouble();
    final merc = math.pi * (1 - 2 * (y / n));
    return (2 * math.atan(math.exp(merc)) - math.pi / 2) * 180.0 / math.pi;
  }

  static TileRange tileRangeForBounds({
    required latlng.LatLng southWest,
    required latlng.LatLng northEast,
    required int z,
  }) {
    final sw = latLonToTileXY(southWest.latitude, southWest.longitude, z);
    final ne = latLonToTileXY(northEast.latitude, northEast.longitude, z);
    final minX = math.min(sw.x, ne.x);
    final maxX = math.max(sw.x, ne.x);
    final minY = math.min(ne.y, sw.y);
    final maxY = math.max(ne.y, sw.y);
    return TileRange(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  static int coarsenZoom(int zReal, int granularityLevels) {
    final z = zReal - granularityLevels;
    return z < 0 ? 0 : (z > 22 ? 22 : z);
  }

  static List<TileCoord> tilesForBounds({
    required LatLngBounds bounds,
    required int zoom,
    int granularityLevels = 0,
  }) {
    final zUsed = coarsenZoom(zoom, granularityLevels);
    final range = tileRangeForBounds(
      southWest: bounds.southWest,
      northEast: bounds.northEast,
      z: zUsed,
    );
    final out = <TileCoord>[];
    for (var x = range.minX; x <= range.maxX; x++) {
      for (var y = range.minY; y <= range.maxY; y++) {
        out.add(TileCoord(x, y, zUsed));
      }
    }
    return out;
  }

  static LatLngBounds approxBoundsAround(
    latlng.LatLng center, {
    double meters = 800,
  }) {
    final dLat = meters / 111000.0;
    final dLon =
        meters / (111000.0 * math.cos(center.latitude * math.pi / 180.0));
    return LatLngBounds(
      latlng.LatLng(center.latitude - dLat, center.longitude - dLon),
      latlng.LatLng(center.latitude + dLat, center.longitude + dLon),
    );
  }

  static List<latlng.LatLng> tileOutline({
    required int x,
    required int y,
    required int z,
  }) {
    final west = tile2lon(x, z);
    final east = tile2lon(x + 1, z);
    final north = tile2lat(y, z);
    final south = tile2lat(y + 1, z);
    final nw = latlng.LatLng(north, west);
    final ne = latlng.LatLng(north, east);
    final se = latlng.LatLng(south, east);
    final sw = latlng.LatLng(south, west);
    return [nw, ne, se, sw, nw];
  }
}
