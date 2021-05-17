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
  Widget get toMarker => const FromMarkerDefault();

  @override
  Widget get fromMarker => const ToMarkerDefault();

  @override
  Widget get yourLocationMarker => const MyLocationMarker();

  @override
  MarkerLayerOptions buildToMarkerLayer(LatLng point) {
    return MarkerLayerOptions(markers: [
      Marker(
        point: point,
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (context) {
          return toMarker;
        },
      )
    ]);
  }

  @override
  MarkerLayerOptions buildFromMarkerLayer(LatLng point) {
    return MarkerLayerOptions(markers: [
      Marker(
        point: point,
        width: 24.0,
        height: 24.0,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        builder: (context) {
          return fromMarker;
        },
      )
    ]);
  }

  @override
  MarkerLayerOptions buildYourLocationMarkerLayer(LatLng point) {
    return MarkerLayerOptions(
      markers: [
        if (point != null)
          Marker(
            width: 50.0,
            height: 50.0,
            point: point,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) => const MyLocationMarker(),
          )
      ],
    );
  }
}
