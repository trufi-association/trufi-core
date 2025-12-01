import 'dart:math';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

Itinerary? itineraryForPoint(
  List<Itinerary> itineraries,
  TrufiLatLng point,
) {
  Itinerary? minPolyline;
  double minDist = double.maxFinite;
  for (final Itinerary itinerary in itineraries) {
    for (final Leg leg in itinerary.compressLegs) {
      for (int i = 0; i < leg.accumulatedPoints.length - 1; i++) {
        final double dist = _distToSegment(
          point,
          (leg.accumulatedPoints[i]),
          (leg.accumulatedPoints[i + 1]),
        );
        if (dist < minDist) {
          minDist = dist;
          minPolyline = itinerary;
        }
      }
    }
  }
  return minPolyline;
}

TrufiLatLng midPointForPoints(List<TrufiLatLng> points) {
  final double midPointLength = _lengthForPolyline(points) / 2;
  double totalLength = 0.0;
  if (points.length >= 2) {
    for (int i = 0; i < points.length - 1; i++) {
      final TrufiLatLng p0 = points[i];
      final TrufiLatLng p1 = points[i + 1];
      final double segmentLength = _dist2(p0, p1);
      totalLength += segmentLength;
      if (midPointLength < totalLength) {
        final double factor1 = (totalLength - midPointLength) / segmentLength;
        final double factor0 = 1.0 - factor1;
        final double latitude = p0.latitude * factor0 + p1.latitude * factor1;
        final double longitude =
            p0.longitude * factor0 + p1.longitude * factor1;
        return TrufiLatLng(latitude, longitude);
      }
    }
  }
  return points[0];
}

double _sqr(double x) {
  return x * x;
}

double _dist2(TrufiLatLng v, TrufiLatLng w) {
  return _sqr(v.longitude - w.longitude) + _sqr(v.latitude - w.latitude);
}

double _distToSegment(TrufiLatLng p, TrufiLatLng v, TrufiLatLng w) {
  return sqrt(_distToSegmentSquared(p, v, w));
}

double _distToSegmentSquared(TrufiLatLng p, TrufiLatLng v, TrufiLatLng w) {
  final double l2 = _dist2(v, w);
  if (l2 == 0) return _dist2(p, v);
  double t = ((p.longitude - v.longitude) * (w.longitude - v.longitude) +
          (p.latitude - v.latitude) * (w.latitude - v.latitude)) /
      l2;
  t = max(0.0, min(1.0, t));
  return _dist2(
      p,
      TrufiLatLng(v.latitude + t * (w.latitude - v.latitude),
          v.longitude + t * (w.longitude - v.longitude)));
}

double _lengthForPolyline(List<TrufiLatLng> points) {
  double totalLength = 0.0;
  for (int i = 0; i < points.length - 1; i++) {
    totalLength += _dist2(points[i], points[i + 1]);
  }
  return totalLength;
}
