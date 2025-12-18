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
    this.imageKey,
    this.metersRadius,
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

  /// Optional radius in meters for geo-scaled markers.
  /// When set, the marker size will scale with map zoom to represent
  /// real-world distance. The [size] property is ignored when this is set.
  final double? metersRadius;

  /// Optional stable key for image caching in MapLibre.
  ///
  /// When rendering markers, MapLibre converts each widget to a PNG image.
  /// By default, it uses `widget.hashCode` as the cache key. However,
  /// since Flutter widgets are immutable and recreated each frame,
  /// the hashCode changes every time, causing:
  ///
  /// - Repeated expensive widget-to-PNG conversions
  /// - Multiple JNI calls to upload images to native layer
  /// - Memory pressure from duplicate cached images
  ///
  /// By providing a stable [imageKey] based on visual properties,
  /// markers with identical appearance share the same cached image.
  ///
  /// Example for animated markers:
  /// ```dart
  /// TrufiMarker(
  ///   id: 'vehicle-1',
  ///   position: currentPosition,
  ///   widget: VehicleWidget(color: Colors.blue, icon: Icons.bus),
  ///   // Key based on visual properties, not position or id
  ///   imageKey: 'vehicle_${Colors.blue.toARGB32()}_${Icons.bus.codePoint}',
  /// )
  /// ```
  final String? imageKey;

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
    String? imageKey,
    double? metersRadius,
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
      imageKey: imageKey ?? this.imageKey,
      metersRadius: metersRadius ?? this.metersRadius,
    );
  }

  Future<TrufiMarker> withGeneratedBytes(BuildContext context) async {
    final bytes = await ImageTool.widgetToBytes(this, context);
    return copyWith(widgetBytes: bytes);
  }
}
