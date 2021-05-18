import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong/latlong.dart';

import 'marker_configuration.dart';
import 'markers_default/from_marker_default.dart';
import 'markers_default/to_marker_default.dart';
import 'markers_default/your_location_marker.dart';

class MarkerConfigurationDefault implements MarkerConfiguration {
  const MarkerConfigurationDefault();

  @override
  Widget get fromMarker => const FromMarkerDefault();

  @override
  Widget get toMarker => const ToMarkerDefault();

  @override
  Widget get yourLocationMarker => const MyLocationMarker();

  @override
  Marker buildFromMarker(LatLng point) {
    return Marker(
      point: point,
      width: 24.0,
      height: 24.0,
      anchorPos: AnchorPos.align(AnchorAlign.center),
      builder: (context) {
        return fromMarker;
      },
    );
  }

  @override
  Marker buildToMarker(LatLng point) {
    return Marker(
      point: point,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (context) {
        return toMarker;
      },
    );
  }

  @override
  Marker buildYourLocationMarker(LatLng point) {
    return (point != null)
        ? Marker(
            width: 50.0,
            height: 50.0,
            point: point,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) => const MyLocationMarker(),
          )
        : Marker(width: 0, height: 0);
  }

  @override
  MarkerLayerOptions buildFromMarkerLayerOptions(LatLng point) {
    return MarkerLayerOptions(markers: [buildFromMarker(point)]);
  }

  @override
  MarkerLayerOptions buildToMarkerLayerOptions(LatLng point) {
    return MarkerLayerOptions(markers: [buildToMarker(point)]);
  }

  @override
  MarkerLayerOptions buildYourLocationMarkerLayerOptions(LatLng point) {
    return MarkerLayerOptions(markers: [buildYourLocationMarker(point)]);
  }
}
