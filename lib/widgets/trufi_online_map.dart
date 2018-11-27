import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnlineMap extends StatefulWidget {
  TrufiOnlineMap({
    Key key,
    @required this.controller,
    @required this.layerOptionsBuilder,
    this.onTap,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiMapController controller;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiOnlineMapState createState() => TrufiOnlineMapState();
}

class TrufiOnlineMapState extends State<TrufiOnlineMap> {

  @override
  Widget build(BuildContext context) {
    return TrufiMap(
      key: ValueKey("TrufiOnlineMap"),
      controller: widget.controller,
      mapOptions: MapOptions(
        minZoom: 1.0,
        maxZoom: 19.0,
        zoom: 13.0,
        onTap: widget.onTap,
        onPositionChanged: _handleOnPositionChanged,
        center: TrufiMap.cochabambaCenter,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          tileHostingTileLayerOptions(),
        ]..addAll(widget.layerOptionsBuilder(context));
      },
    );
  }

  void _handleOnPositionChanged(MapPosition position) {
    if (widget.onPositionChanged != null) {
      Future.delayed(Duration.zero, () {
        widget.onPositionChanged(position);
      });
    }
  }
}