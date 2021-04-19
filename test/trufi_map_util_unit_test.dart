import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/trufi_map_utils.dart';
import 'package:trufi_core/trufi_models.dart';

void main() {
  const double _latitude = 18.0;
  const double _longitude = 129.0;
  final LatLng _point = LatLng(_latitude, _longitude);
  PlanItineraryLeg _leg;
  
  setUp((){
    _leg = PlanItineraryLeg(
        points: "points",
        mode: "WALK",
        route: "123",
        routeLongName: "long_name_route",
        duration: 300.0,
        distance: 2.0);
  });

  test('Build from Marker', () {
    final Marker marker = buildFromMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build to Marker', () {
    final Marker marker = buildToMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build Your location Marker', () {
    final Marker marker = buildYourLocationMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build bus Marker', () {
    final Marker marker = buildBusMarker(_point, Colors.black, _leg);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });
}
