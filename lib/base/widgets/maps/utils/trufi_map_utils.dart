import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';

class PolylineWithMarkers {
  PolylineWithMarkers(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}

Itinerary? itineraryForPoint(
    Map<Itinerary, List<PolylineWithMarkers>> itineraries,
    List<Polyline> polylines,
    LatLng point) {
  return _itineraryForPolyline(itineraries, _polylineHitTest(polylines, point));
}

Itinerary? _itineraryForPolyline(
    Map<Itinerary, List<PolylineWithMarkers>> itineraries, Polyline? polyline) {
  final entry = _itineraryEntryForPolyline(itineraries, polyline);
  return entry?.key;
}

MapEntry<Itinerary, List<PolylineWithMarkers>>? _itineraryEntryForPolyline(
  Map<Itinerary, List<PolylineWithMarkers>> itineraries,
  Polyline? polyline,
) {
  return itineraries.entries.firstWhereOrNull((pair) {
    return null !=
        pair.value.firstWhereOrNull(
          (pwm) => pwm.polyline == polyline,
        );
  });
}

Polyline? _polylineHitTest(List<Polyline> polylines, LatLng point) {
  Polyline? minPolyline;
  double minDist = double.maxFinite;
  for (final Polyline p in polylines) {
    for (int i = 0; i < p.points.length - 1; i++) {
      final double dist = distToSegment(point, p.points[i], p.points[i + 1]);
      if (dist < minDist) {
        minDist = dist;
        minPolyline = p;
      }
    }
  }
  return minPolyline;
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
          child: const Icon(Icons.circle_outlined, color: Colors.white),
        ),
      );
    },
  );
}

Marker buildTransportMarker(
  LatLng point,
  Color color,
  Leg leg, {
  VoidCallback? onTap,
  bool showIcon = true,
  bool showText = true,
}) {
  return Marker(
    width: 50.0,
    point: point,
    anchorPos: AnchorPos.align(AnchorAlign.center),
    builder: (context) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              if (showIcon)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: leg.transportMode.getImage(color: Colors.white),
                ),
              if (showText)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    leg.route?.shortName ?? leg.headSign,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
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
  Decoration? decoration,
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
  final double l2 = dist2(v, w);
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

double lengthForPolyline(List<LatLng> points) {
  double totalLength = 0.0;
  for (int i = 0; i < points.length - 1; i++) {
    totalLength += dist2(points[i], points[i + 1]);
  }
  return totalLength;
}

LatLng midPointForPoints(List<LatLng> points) {
  final double midPointLength = lengthForPolyline(points) / 2;
  double totalLength = 0.0;
  if (points.length >= 2) {
    for (int i = 0; i < points.length - 1; i++) {
      final LatLng p0 = points[i];
      final LatLng p1 = points[i + 1];
      final double segmentLength = dist2(p0, p1);
      totalLength += segmentLength;
      if (midPointLength < totalLength) {
        final double factor1 = (totalLength - midPointLength) / segmentLength;
        final double factor0 = 1.0 - factor1;
        final double latitude = p0.latitude * factor0 + p1.latitude * factor1;
        final double longitude =
            p0.longitude * factor0 + p1.longitude * factor1;
        return LatLng(latitude, longitude);
      }
    }
  }
  return points[0];
}
