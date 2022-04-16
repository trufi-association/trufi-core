import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

List<LatLng> decodePolyline(String? encoded) {
  if (encoded == null) return [];
  if (kIsWeb) {
    return _decodePolylineWeb(encoded);
  } else {
    return _decodePolylineDefault(encoded);
  }
}

List<LatLng> _decodePolylineDefault(String encoded) {
  final List<LatLng> points = <LatLng>[];
  int index = 0;
  final int len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;
    shift = 0;
    result = 0;
    const compare = 0x20;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= compare);
    final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;
    try {
      final LatLng p = LatLng(lat / 1E5, lng / 1E5);
      points.add(p);
    } catch (e) {
      log(e.toString());
    }
  }
  return points;
}

List<LatLng> _decodePolylineWeb(String encoded) {
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
