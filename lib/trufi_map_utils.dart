import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:latlong/latlong.dart';

import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_models.dart';

openStreetMapTileLayerOptions() {
  return TileLayerOptions(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c'],
  );
}

offlineMapTileLayerOptions() {
  return TileLayerOptions(
    offlineMode: true,
    maxZoom: 18.0,
    urlTemplate: "assets/tiles/{z}/{z}-{x}-{y}.png",
  );
}

tileHostingTileLayerOptions() {
  return TileLayerOptions(
    urlTemplate:
        "https://maps.tilehosting.com/styles/streets/{z}/{x}/{y}.png?key={key}",
    additionalOptions: {
      'key': '***REMOVED***',
    },
  );
}

Marker buildFromMarker(LatLng point) {
  return Marker(
    point: point,
    anchorPos: AnchorPos.align(AnchorAlign.top),
    builder: (context) {
      return Container(
        child: SvgPicture.asset(
          "assets/images/from_marker.svg",
        ),
      );
    },
  );
}

Marker buildToMarker(LatLng point) {
  return Marker(
    point: point,
    anchorPos: AnchorPos.align(AnchorAlign.top),
    builder: (context) {
      return Container(
        child: SvgPicture.asset(
          "assets/images/to_marker.svg",
        ),
      );
    },
  );
}

Marker buildTransferMarker(LatLng point) {
  return Marker(
    point: point,
    anchorPos: AnchorPos.align(AnchorAlign.center),
    builder: (context) {
      return Transform.scale(
        scale: 0.4,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 3.5),
            shape: BoxShape.circle,
          ),
          child: Icon(CircleIcon.circle),
        ),
      );
    },
  );
}

Marker buildYourLocationMarker(LatLng point) {
  return Marker(
    width: 50.0,
    height: 50.0,
    point: point,
    anchorPos: AnchorPos.align(AnchorAlign.center),
    builder: (context) => MyLocationMarker(),
  );
}

class MyLocationMarker extends StatefulWidget {
  @override
  MyLocationMarkerState createState() => MyLocationMarkerState();
}

class MyLocationMarkerState extends State<MyLocationMarker> {
  final _subscriptions = CompositeSubscription();

  double _direction;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      FlutterCompass.events.listen((double direction) {
        setState(() {
          _direction = direction;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      Center(
        child: Transform.scale(
          scale: 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              border: Border.all(color: Colors.white, width: 3.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).accentColor,
                  spreadRadius: 8.0,
                  blurRadius: 30.0,
                ),
              ],
            ),
            child: Icon(
              CircleIcon.circle,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    ];
    if (_direction != null) {
      children.add(
        Transform.rotate(
          angle: (pi / 180.0) * _direction,
          child: Container(
            alignment: Alignment.topCenter,
            child: Icon(
              Icons.arrow_drop_up,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      );
    }
    return Stack(children: children);
  }
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
    anchorPos: AnchorPos.align(AnchorAlign.center),
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
                  Icon(leg.iconData()),
                  Text(leg.route),
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
  AnchorPos anchorPos,
  Color color, {
  Decoration decoration,
}) {
  return Marker(
    point: point,
    anchorPos: anchorPos,
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

class CircleIcon {
  CircleIcon._();

  static const _kFontFam = 'CircleIcon';

  static const IconData circle = const IconData(0xf111, fontFamily: _kFontFam);
}

class GondolaIcon {
  GondolaIcon._();

  static const _kFontFam = 'GondolaIcon';

  static const IconData gondola = const IconData(0xe900, fontFamily: _kFontFam);
}