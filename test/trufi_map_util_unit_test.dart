import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/markers/marker_configuration.dart';
import 'package:trufi_core/models/markers/marker_configuration_default.dart';
import 'package:trufi_core/widgets/map/utils/trufi_map_utils.dart';

void main() {
  const double _latitude = 18.0;
  const double _longitude = 129.0;
  final LatLng _point = LatLng(_latitude, _longitude);
  PlanItineraryLeg _leg;
  const MarkerConfiguration markers = MarkerConfigurationDefault();
  setUp(() {
    _leg = PlanItineraryLeg(
        points: "points",
        mode: "WALK",
        route: "123",
        routeLongName: "long_name_route",
        duration: 300.0,
        distance: 2.0);
  });

  test('Build from Marker', () {
    final MarkerLayerOptions marker =
        markers.buildFromMarkerLayerOptions(_point);
    expect(marker, isNotNull);
    expect(marker.markers[0].point, _point);
  });

  test('Build to Marker', () {
    final MarkerLayerOptions marker = markers.buildToMarkerLayerOptions(_point);
    expect(marker, isNotNull);
    expect(marker.markers[0].point, _point);
  });

  test('Build bus Marker', () {
    final Marker marker = buildBusMarker(_point, Colors.black, _leg);
    expect(marker, isNotNull);
    expect(marker.point, _point);
  });
}
