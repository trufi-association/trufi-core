import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../../data/utils/image_tool.dart';

class TrufiMarker {
  TrufiMarker({
    required this.id,
    required this.position,
    required this.widget,
    this.buildPanel,
    this.widgetBytes,
    this.layerLevel = 1,
    this.size = const Size(30, 30),
    this.rotation = 0,
    this.alignment = Alignment.center,
  });

  final String id;
  final latlng.LatLng position;
  final Widget widget;
  final WidgetBuilder? buildPanel;
  Uint8List? widgetBytes;
  final int layerLevel;
  final Size size;
  final double rotation;
  final Alignment alignment;

  Future<void> generateBytes(BuildContext context) async {
    widgetBytes = await ImageTool.widgetToBytes(this, context);
  }
}
