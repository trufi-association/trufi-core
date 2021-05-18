import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

abstract class MarkerConfiguration {
  Widget get toMarker;
  Widget get fromMarker;
  Widget get yourLocationMarker;

  Marker buildToMarker(LatLng point);
  Marker buildFromMarker(LatLng point);
  Marker buildYourLocationMarker(LatLng point);

  MarkerLayerOptions buildToMarkerLayerOptions(LatLng point);
  MarkerLayerOptions buildFromMarkerLayerOptions(LatLng point);
  MarkerLayerOptions buildYourLocationMarkerLayerOptions(LatLng point);
}
