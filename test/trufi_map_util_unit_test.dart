import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:test/test.dart';

import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/trufi_models.dart';

void main() {
  double _latitude = 18.0;
  double _longitude = 129.0;
  LatLng _point = new LatLng(_latitude, _longitude);
  PlanItineraryLeg _leg;
  
  setUp((){
    _leg = new PlanItineraryLeg(
        points: "points",
        mode: "WALK",
        route: "123",
        routeLongName: "long_name_route",
        duration: 300.0,
        distance: 2.0);
  });

  test('Build from Marker', () {
    Marker marker = buildFromMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build to Marker', () {
    Marker marker = buildToMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build Your location Marker', () {
    Marker marker = buildYourLocationMarker(_point);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });

  test('Build bus Marker', () {
    Marker marker = buildBusMarker(_point, Colors.black, _leg);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });
}
