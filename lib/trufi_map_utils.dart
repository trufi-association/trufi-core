import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_models.dart';

openStreetMapTileLayerOptions() {
  return new TileLayerOptions(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c']);
}

mapBoxTileLayerOptions() {
  return new TileLayerOptions(
    urlTemplate: "https://api.tiles.mapbox.com/v4/"
        "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
    additionalOptions: {
      'accessToken':
      'pk.eyJ1IjoicmF4ZGEiLCJhIjoiY2plZWI4ZGNtMDhjdDJ4cXVzbndzdjJrdCJ9.glZextqSSPedd2MudTlMbQ',
      'id': 'mapbox.streets',
    },
  );
}

Marker buildFromMarker(LatLng latLng) {
  return buildMarker(latLng, Icons.adjust, AnchorPos.center, Colors.blue);
}

Marker buildToMarker(LatLng latLng) {
  return buildMarker(latLng, Icons.location_on, AnchorPos.top, Colors.red);
}

Marker buildMarker(
    LatLng latLng, IconData iconData, AnchorPos anchor, Color color) {
  return new Marker(
    point: latLng,
    anchor: anchor,
    builder: (context) =>
    new Container(child: new Icon(iconData, color: color)),
  );
}

LatLng createLatLngWithPlanLocation(PlanLocation location) {
  return LatLng(location.latitude, location.longitude);
}

Map<PlanItinerary, List<Polyline>> createItineraries(
    Plan plan, PlanItinerary selectedItinerary) {
  Map<PlanItinerary, List<Polyline>> itineraries = Map();
  plan.itineraries.forEach((itinerary) {
    List<Polyline> polylines = List();
    bool isSelected = itinerary == selectedItinerary;
    itinerary.legs.forEach((leg) {
      List<LatLng> points = decodePolyline(leg.points);
      Polyline polyline = new Polyline(
          points: points,
          color: isSelected
              ? leg.mode == 'WALK' ? Colors.blue : Colors.green
              : Colors.grey,
          strokeWidth: isSelected ? 6.0 : 3.0);
      polylines.add(polyline);
    });
    itineraries.addAll({itinerary: polylines});
  });
  return itineraries;
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> points = new List<LatLng>();
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
    LatLng p = new LatLng(lat / 1E5, lng / 1E5);
    points.add(p);
  }
  return points;
}

Polyline polylineHitTest(List<Polyline> polylines, LatLng point) {
  Polyline minPolyline;
  double minDist = double.maxFinite;
  polylines.forEach((p) {
    for (int i = 0; i < p.points.length - 1; i++) {
      double dist = distToSegment(point, p.points[i], p.points[i + 1]);
      if (dist < minDist) {
        minDist = dist;
        minPolyline = p;
      }
    }
  });
  return minPolyline;
}

double sqr(double x) {
  return x * x;
}

double dist2(LatLng v, LatLng w) {
  return sqr(v.longitude - w.longitude) + sqr(v.latitude - w.latitude);
}

double distToSegment(LatLng p, LatLng v, LatLng w) {
  return sqrt(distToSegmentSquared(p, v, w));
}

double distToSegmentSquared(LatLng p, LatLng v, LatLng w) {
  double l2 = dist2(v, w);
  if (l2 == 0) return dist2(p, v);
  double t = ((p.longitude - v.longitude) * (w.longitude - v.longitude) +
      (p.latitude - v.latitude) * (w.latitude - v.latitude)) /
      l2;
  t = max(0.0, min(1.0, t));
  return dist2(
      p,
      LatLng(v.latitude + t * (w.latitude - v.latitude),
          v.longitude + t * (w.longitude - v.longitude)));
}
