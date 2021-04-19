import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/preferences/preferences_bloc.dart';
import 'package:trufi_core/models/preferences.dart';

import '../trufi_configuration.dart';
import '../trufi_map_utils.dart';
import '../widgets/trufi_map.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnlineMap extends StatefulWidget {
  const TrufiOnlineMap({
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
    final test = BlocProvider.of<PreferencesBloc>(context).stream;
    final cfg = TrufiConfiguration();
    return StreamBuilder(
      stream: test,
      builder: (BuildContext context, AsyncSnapshot<Preference> snapshot) {
        return TrufiMap(
          key: const ValueKey("TrufiOnlineMap"),
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
                getTilesEndpointForMapType(snapshot.data.currentMapType),
                tileProviderKey: cfg.map.mapTilerKey,
              ),
              ...widget.layerOptionsBuilder(context),
            ];
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
