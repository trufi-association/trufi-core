import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/trufi_models.dart';

import '../trufi_configuration.dart';
import '../trufi_map_utils.dart';
import '../widgets/trufi_map.dart';

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
    final preferencesBloc = PreferencesBloc.of(context);
    final cfg = TrufiConfiguration();
    return StreamBuilder(
      stream: preferencesBloc.outChangeMapType,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TrufiMap(
          key: ValueKey("TrufiOnlineMap"),
          controller: widget.controller,
          mapOptions: MapOptions(
            minZoom: cfg.map.onlineMinZoom,
            maxZoom: cfg.map.onlineMaxZoom,
            zoom: cfg.map.onlineZoom,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onPositionChanged: _handleOnPositionChanged,
            center: cfg.map.center,
          ),
          layerOptionsBuilder: (context) {
            return <LayerOptions>[
              tileHostingTileLayerOptions(
                getTilesEndpointForMapType(snapshot.data),
                fileFormat: snapshot.data == MapStyle.satellite ? 'jpg' : 'png',
                tileProviderKey: cfg.map.mapTilerKey,
              ),
            ]..addAll(widget.layerOptionsBuilder(context));
          },
        );
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
