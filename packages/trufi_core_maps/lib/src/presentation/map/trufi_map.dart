import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../../domain/controller/map_controller.dart';

abstract class TrufiMap extends Widget {
  final TrufiMapController controller;
  final void Function(latlng.LatLng)? onMapClick;
  final void Function(latlng.LatLng)? onMapLongClick;

  const TrufiMap({
    super.key,
    required this.controller,
    required this.onMapClick,
    required this.onMapLongClick,
  });
}
