import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

abstract class MarkerConfiguration {
  Widget get toMarker;
  Widget get fromMarker;
  Widget get yourLocationMarker;

  MarkerLayerOptions buildToMarkerLayer(LatLng point);
  MarkerLayerOptions buildFromMarkerLayer(LatLng point);
  MarkerLayerOptions buildYourLocationMarkerLayer(LatLng point);
}
