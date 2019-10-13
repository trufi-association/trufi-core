import 'dart:async';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnlineMap extends StatefulWidget {
  TrufiOnlineMap({
    Key key,
    @required this.controller,
    @required this.layerOptionsBuilder,
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiMapController controller;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final LongPressCallback onLongPress;
  final PositionCallback onPositionChanged;

  @override
  TrufiOnlineMapState createState() => TrufiOnlineMapState();
}

class TrufiOnlineMapState extends State<TrufiOnlineMap> {
  @override
  Widget build(BuildContext context) {
    final cfg = GlobalConfiguration();
    final minZoom = cfg.getDouble("mapOnlineMinZoom");
    final maxZoom = cfg.getDouble("mapOnlineMaxZoom");
    final zoom = cfg.getDouble("mapOnlineZoom");
    final centerCoords = List<double>.from(cfg.get("mapCenterCoordsLatLng"));
    final mapCenter = LatLng(centerCoords[0], centerCoords[1]);

    return TrufiMap(
      key: ValueKey("TrufiOnlineMap"),
      controller: widget.controller,
      mapOptions: MapOptions(
        minZoom: minZoom,
        maxZoom: maxZoom,
        zoom: zoom,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPositionChanged: _handleOnPositionChanged,
        center: mapCenter,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          tileHostingTileLayerOptions(),
        ]..addAll(widget.layerOptionsBuilder(context));
      },
    );
  }

  void _handleOnPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (widget.onPositionChanged != null) {
      Future.delayed(Duration.zero, () {
        widget.onPositionChanged(position, hasGesture);
      });
    }
  }
}
