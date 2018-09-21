import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_app/trufi_models.dart';

class PolylineWithMarker {
  PolylineWithMarker(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}

openStreetMapTileLayerOptions() {
  return TileLayerOptions(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c'],
  );
}

tileHostingTileLayerOptions() {
  return TileLayerOptions(
    urlTemplate:
        "https://maps.tilehosting.com/styles/positron/{z}/{x}/{y}.png?key={key}",
    additionalOptions: {
      'key': 'QNVqPrA4XDeyff2S5h6S',
    },
  );
}

Marker buildFromMarker(LatLng point) {
  return buildMarker(point, Icons.adjust, AnchorPos.center, Colors.black);
}

Marker buildToMarker(LatLng point) {
  return Marker(
    point: point,
    anchor: AnchorPos.top,
    builder: (context) {
      return Container(
        child: SvgPicture.asset(
          "assets/images/map_marker.svg",
        ),
      );
    },
  );
}

Marker buildTransferMarker(LatLng point) {
  return Marker(
    point: point,
    anchor: AnchorPos.center,
    builder: (context) {
      return ScaleTransition(
        scale: AlwaysStoppedAnimation<double>(0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 3.5),
            shape: BoxShape.circle,
          ),
          child: Icon(CircleIcon.circle, color: Colors.white),
        ),
      );
    },
  );
}

Marker buildYourLocationMarker(LatLng point) {
  return Marker(
    point: point,
    anchor: AnchorPos.center,
    builder: (context) {
      return ScaleTransition(
        scale: AlwaysStoppedAnimation<double>(0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 3.5),
            shape: BoxShape.circle,
            boxShadow: [
              new BoxShadow(
                color: Colors.blue,
                spreadRadius: 8.0,
                blurRadius: 30.0,
              ),
            ],
          ),
          child: Icon(CircleIcon.circle, color: Colors.blue),
        ),
      );
    },
  );
}

Marker buildBusMarker(
  LatLng point,
  Color color,
  PlanItineraryLeg leg, {
  Function onTap,
}) {
  return Marker(
    width: 50.0,
    height: 30.0,
    point: point,
    anchor: AnchorPos.center,
    builder: (context) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: <Widget>[
                  Icon(leg.iconData(), color: Colors.white),
                  Text(leg.route, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
  );
}

Marker buildMarker(
  LatLng point,
  IconData iconData,
  AnchorPos anchor,
  Color color, {
  Decoration decoration,
}) {
  return Marker(
    point: point,
    anchor: anchor,
    builder: (context) {
      return Container(
        decoration: decoration,
        child: Icon(iconData, color: color),
      );
    },
  );
}

LatLng createLatLngWithPlanLocation(PlanLocation location) {
  return LatLng(location.latitude, location.longitude);
}

Map<PlanItinerary, List<PolylineWithMarker>> createItineraries(
  Plan plan,
  PlanItinerary selectedItinerary,
  Function(PlanItinerary) onTap,
) {
  Map<PlanItinerary, List<PolylineWithMarker>> itineraries = Map();
  var markers = List<Marker>();
  plan.itineraries.forEach((itinerary) {
    var legsAmount = itinerary.legs.length;
    List<PolylineWithMarker> polylinesWithMarker = List();
    bool isSelected = itinerary == selectedItinerary;
    for (var i = 0; i < legsAmount; i++) {
      var leg = itinerary.legs[i];

      List<LatLng> points = decodePolyline(leg.points);
      Polyline polyline = new Polyline(
        points: points,
        color: isSelected
            ? leg.mode == 'WALK' ? Colors.blue : Colors.green
            : Colors.grey,
        strokeWidth: isSelected ? 6.0 : 3.0,
        borderColor: Colors.white,
        borderStrokeWidth: 3.0,
        isDotted: leg.mode == 'WALK',
      );

      // Create bus marker
      if (leg.mode != 'WALK' && isSelected) {
        markers.add(
          buildBusMarker(
            midPointForPolyline(polyline),
            isSelected ? Colors.green : Colors.grey,
            leg,
            onTap: () => onTap(itinerary),
          ),
        );
      }

      // Create transfer markers
      if (isSelected && i < legsAmount - 1) {
        Marker end = buildTransferMarker(lastPointForPolyline(polyline));
        markers.add(end);
      }
      polylinesWithMarker.add(PolylineWithMarker(polyline, markers));
    }
    itineraries.addAll({itinerary: polylinesWithMarker});
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

double lengthForPolyline(Polyline polyline) {
  double totalLength = 0.0;
  for (int i = 0; i < polyline.points.length - 1; i++) {
    totalLength += dist2(polyline.points[i], polyline.points[i + 1]);
  }
  return totalLength;
}

LatLng midPointForPolyline(Polyline polyline) {
  double midPointLength = lengthForPolyline(polyline) / 2;
  double totalLength = 0.0;
  for (int i = 0; i < polyline.points.length - 1; i++) {
    LatLng p0 = polyline.points[i];
    LatLng p1 = polyline.points[i + 1];
    double segmentLength = dist2(p0, p1);
    totalLength += segmentLength;
    if (midPointLength < totalLength) {
      double factor1 = (totalLength - midPointLength) / segmentLength;
      double factor0 = 1.0 - factor1;
      double latitude = p0.latitude * factor0 + p1.latitude * factor1;
      double longitude = p0.longitude * factor0 + p1.longitude * factor1;
      return LatLng(latitude, longitude);
    }
  }
  return null;
}

LatLng lastPointForPolyline(Polyline polyline) {
  return polyline.points[polyline.points.length - 1];
}

class CircleIcon {
  CircleIcon._();

  static const _kFontFam = 'CircleIcon';

  static const IconData circle = const IconData(0xf111, fontFamily: _kFontFam);
}
