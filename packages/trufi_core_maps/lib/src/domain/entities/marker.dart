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
  final Uint8List? widgetBytes;
  final int layerLevel;
  final Size size;
  final double rotation;
  final Alignment alignment;

  TrufiMarker copyWith({
    String? id,
    latlng.LatLng? position,
    Widget? widget,
    WidgetBuilder? buildPanel,
    Uint8List? widgetBytes,
    int? layerLevel,
    Size? size,
    double? rotation,
    Alignment? alignment,
  }) {
    return TrufiMarker(
      id: id ?? this.id,
      position: position ?? this.position,
      widget: widget ?? this.widget,
      buildPanel: buildPanel ?? this.buildPanel,
      widgetBytes: widgetBytes ?? this.widgetBytes,
      layerLevel: layerLevel ?? this.layerLevel,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      alignment: alignment ?? this.alignment,
    );
  }

  Future<TrufiMarker> withGeneratedBytes(BuildContext context) async {
    final bytes = await ImageTool.widgetToBytes(this, context);
    return copyWith(widgetBytes: bytes);
  }
}
