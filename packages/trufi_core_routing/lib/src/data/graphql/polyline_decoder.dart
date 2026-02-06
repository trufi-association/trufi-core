import 'package:latlong2/latlong.dart';

/// Encodes and decodes Google-encoded polyline strings.
class PolylineCodec {
  PolylineCodec._();

  /// Encodes a list of coordinates to a polyline string.
  ///
  /// This implements the Google Polyline Algorithm:
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  static String encode(List<LatLng> points) {
    if (points.isEmpty) return '';

    final buffer = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      final lat = (point.latitude * 1e5).round();
      final lng = (point.longitude * 1e5).round();

      _encodeValue(lat - prevLat, buffer);
      _encodeValue(lng - prevLng, buffer);

      prevLat = lat;
      prevLng = lng;
    }

    return buffer.toString();
  }

  static void _encodeValue(int value, StringBuffer buffer) {
    // Zigzag encode
    int encoded = value < 0 ? ((-value) << 1) - 1 : value << 1;

    while (encoded >= 0x20) {
      buffer.writeCharCode(((encoded & 0x1f) | 0x20) + 63);
      encoded >>= 5;
    }
    buffer.writeCharCode(encoded + 63);
  }
}

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

    return points;
  }
}
