import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/widgets/maps/markers/base_marker/from_marker.dart';
import 'package:trufi_core/base/widgets/maps/markers/base_marker/my_location_marker.dart';
import 'package:trufi_core/base/widgets/maps/markers/base_marker/to_marker.dart';

part 'marker_configuration_default.dart';

abstract class MarkerConfiguration {
  Widget get toMarker;
  Widget get fromMarker;
  Widget get yourLocationMarker;

  Marker buildToMarker(LatLng point);
  Marker buildFromMarker(LatLng point);
  Marker buildYourLocationMarker(LatLng point);

  MarkerLayerOptions buildToMarkerLayerOptions(LatLng point);
  MarkerLayerOptions buildFromMarkerLayerOptions(LatLng point);
  MarkerLayerOptions buildYourLocationMarkerLayerOptions(LatLng? point);
}
