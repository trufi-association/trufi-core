import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Utility class for map-related operations.
///
/// @deprecated Use [PolylineDecoder] from trufi_core_routing instead.
abstract class TrufiMapUtils {
  /// Decodes an encoded polyline string to a list of coordinates.
  ///
  /// Uses platform-specific implementation for web compatibility.
  static List<LatLng> decodePolyline(String? encoded) {
    if (encoded == null) return [];
    if (kIsWeb) {
      return _decodePolylineWeb(encoded);
    } else {
      // Use the decoder from trufi_core_routing package
      return PolylineDecoder.decode(encoded);
    }
  }

  /// Web-specific polyline decoder using BigInt for precision.
  static List<LatLng> _decodePolylineWeb(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    BigInt big0 = BigInt.from(0);
    BigInt big0x1f = BigInt.from(0x1f);
    BigInt big0x20 = BigInt.from(0x20);
    while (index < len) {
      int shift = 0;
      BigInt b, result;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      BigInt rShifted = result >> 1;
      int dLat;
      if (result.isOdd) {
        dLat = (~rShifted).toInt();
      } else {
        dLat = rShifted.toInt();
      }
      lat += dLat;

      shift = 0;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      rShifted = result >> 1;
      int dLng;
      if (result.isOdd) {
        dLng = (~rShifted).toInt();
      } else {
        dLng = rShifted.toInt();
      }
      lng += dLng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }
}
