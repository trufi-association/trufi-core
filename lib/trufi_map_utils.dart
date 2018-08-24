import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

Marker createDestinationMarker(double latitude, double longitude) {
  return createMarker(latitude, longitude, "assets/images/destination_marker.png");
}

Marker createOriginMarker(double latitude, double longitude) {
  return createMarker(latitude, longitude, "assets/images/origin_marker.png");
}

Marker createPositionMarker(double latitude, double longitude) {
  return createMarker(latitude, longitude, "assets/images/position_marker.png");
}

Marker createMarker(double latitude, double longitude, String asset) {
  return new Marker(
    "1",
    "Position",
    latitude,
    longitude,
    color: Colors.blue,
    draggable: true,
    markerIcon: new MarkerIcon(
      asset,
      width: 64.0,
      height: 64.0,
    ),
  );
}

List<Location> decodePolyline(String encoded) {
  List<Location> points = new List<Location>();
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    Location p = new Location(lat / 1E5, lng / 1E5);
    points.add(p);
  }
  return points;
}
