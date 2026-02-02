import 'package:latlong2/latlong.dart';

/// Decodes Google-encoded polyline strings.
class PolylineDecoder {
  PolylineDecoder._();

  /// Decodes an encoded polyline string to a list of coordinates.
  ///
  /// This implements the Google Polyline Algorithm:
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  /// Note: Uses arithmetic instead of bitwise NOT (~) for web compatibility.
  /// In Dart web (JavaScript), bitwise operations on large numbers can produce
  /// unexpected results due to JS's 32-bit integer conversion.
  static List<LatLng> decode(String encoded) {
    print('[PolylineDecoder] Decoding polyline with length: ${encoded.length}');
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      // Decode latitude
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      // Zigzag decode: use arithmetic instead of ~ for web compatibility
      // ~(result >> 1) == -(result >> 1) - 1 == -((result >> 1) + 1)
      lat += (result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      // Zigzag decode: use arithmetic instead of ~ for web compatibility
      lng += (result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    print('[PolylineDecoder] Decoded ${points.length} points');
    if (points.isNotEmpty) {
      print('[PolylineDecoder] First point: ${points.first}');
      print('[PolylineDecoder] Last point: ${points.last}');
    }
    return points;
  }
}
