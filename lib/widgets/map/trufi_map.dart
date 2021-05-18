import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/custom_layer/custom_layers_cubit.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/blocs/map_tile_provider/map_tile_provider_cubit.dart';

import 'trufi_map_controller.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiMap extends StatefulWidget {
  const TrufiMap({
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
  _TrufiMapState createState() => _TrufiMapState();
}

class _TrufiMapState extends State<TrufiMap> {
  int mapZoom;

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    final currentMapType = context.watch<MapTileProviderCubit>().state;
    final currentLocation =
        context.watch<LocationProviderCubit>().state.currentLocation;
    final customLayersCubit = context.watch<CustomLayersCubit>();
    return FlutterMap(
      mapController: widget.controller.mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.pinchZoom |
            InteractiveFlag.drag |
            InteractiveFlag.doubleTapZoom,
        minZoom: cfg.map.onlineMinZoom,
        maxZoom: cfg.map.onlineMaxZoom,
        zoom: cfg.map.onlineZoom,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        center: cfg.map.center,
        onPositionChanged: (
          MapPosition position,
          bool hasGesture,
        ) {
          if (widget.onPositionChanged != null) {
            Future.delayed(Duration.zero, () {
              widget.onPositionChanged(position, hasGesture);
            });
          }
          // fix render issue
          Future.delayed(Duration.zero, () {
            final int zoom = position.zoom.round();
            if (mapZoom != zoom) setState(() => mapZoom = zoom);
          });
        },
      ),
      layers: [
        ...currentMapType.currentMapTileProvider.buildTileLayerOptions(),
        // tileHostingTileLayerOptions(
        //   getTilesEndpointForMapType(currentMapType),
        //   tileProviderKey: cfg.map.mapTilerKey,
        // ),
        ...customLayersCubit.activeCustomLayers(mapZoom),
        cfg.markers.buildYourLocationMarkerLayerOptions(currentLocation),
        ...widget.layerOptionsBuilder(context)
      ],
    );
  }
}
