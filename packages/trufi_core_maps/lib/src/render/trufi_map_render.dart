import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../map/controller.dart';

abstract class TrufiMapRender extends Widget {
  final TrufiMapController controller;
  final void Function(latlng.LatLng)? onMapClick;
  final void Function(latlng.LatLng)? onMapLongClick;

  const TrufiMapRender({
    super.key,
    required this.controller,
    required this.onMapClick,
    required this.onMapLongClick,
  });
}
