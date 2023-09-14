import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

abstract class MapLayer {
  final String id;
  final String weight;
  Function? onRefresh;
  MapLayer(this.id, this.weight);

  void refresh() {
    if (onRefresh != null) onRefresh!();
  }

  Widget buildLayerOptions(int zoom);

  Widget? buildLayerOptionsBackground(int zoom);

  List<Marker>? buildLayerMarkers(int zoom);

  String name(BuildContext context);

  Widget icon(BuildContext context);
}

class MapLayerContainer {
  final List<MapLayer> layers;
  final WidgetBuilder icon;
  final String Function(BuildContext context) name;
  MapLayerContainer({
    required this.layers,
    required this.icon,
    required this.name,
  });
  bool? checkStatus(Map<String, bool> layersSatus) {
    bool active = true;
    bool inactive = false;
    for (final layer in layers) {
      active &= (layersSatus[layer.id] ?? true);
      inactive |= (layersSatus[layer.id] ?? false);
    }
    return active
        ? active
        : !inactive
            ? inactive
            : null;
  }
}
