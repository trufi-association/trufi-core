import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
abstract class CustomLayer {
  final String id;
  Function onRefresh;
  CustomLayer(this.id);

  void refresh() {
    if (onRefresh != null) onRefresh();
  }

  LayerOptions buildLayerOptions(int zoom);

  String name(BuildContext context);
}
