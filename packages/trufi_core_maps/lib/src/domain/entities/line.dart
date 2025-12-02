import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

class TrufiLine {
  TrufiLine({
    required this.id,
    required this.position,
    this.color = Colors.black,
    this.layerLevel = 1,
    this.lineWidth = 2,
    this.activeDots = false,
    this.visible = true,
  });

  final String id;
  final List<latlng.LatLng> position;
  final Color color;
  final int layerLevel;
  final double lineWidth;
  final bool activeDots;
  final bool visible;
}
