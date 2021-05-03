import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/models/map_route_state.dart';

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

// TODO: I would recommend to have here an App State with the Plan, MapTyle, Locations etc.
// Everything that is related to the Map currently we collect from the Preferences
// and the HomePageBloc
class TrufiOnlineMapState extends State<TrufiOnlineMap> {
  @override
  Widget build(BuildContext context) {
    final currentMapType =
        context.watch<PreferencesCubit>().state.currentMapType;
    final cfg = TrufiConfiguration();
    return BlocBuilder<HomePageCubit, MapRouteState>(
      builder: (context, state) => TrufiMap(
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
              getTilesEndpointForMapType(currentMapType),
              tileProviderKey: cfg.map.mapTilerKey,
            ),
            ...widget.layerOptionsBuilder(context),
          ];
        },
      ),
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
