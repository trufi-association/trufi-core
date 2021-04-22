import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/models/preferences.dart';

import '../trufi_configuration.dart';
import '../trufi_map_utils.dart';
import '../widgets/trufi_map.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnAndOfflineMapController {
  TrufiOnAndOfflineMapController() {
    _offlineController.outMapReady.listen((_) => _inMapReady.add(null));
    _onlineController.outMapReady.listen((_) => _inMapReady.add(null));
  }

  final _offlineController = TrufiMapController();
  final _onlineController = TrufiMapController();
  final _mapReadyController = rx.BehaviorSubject<void>();

  void dispose() {
    _offlineController.dispose();
    _onlineController.dispose();
    _mapReadyController.close();
  }

  Sink<void> get _inMapReady => _mapReadyController.sink;

  Stream<void> get outMapReady => _mapReadyController.stream;

  TrufiMapController get offline => _offlineController;

  TrufiMapController get online => _onlineController;
}

class TrufiOnAndOfflineMap extends StatelessWidget {
  const TrufiOnAndOfflineMap({
    Key key,
    @required this.controller,
    @required this.layerOptionsBuilder,
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiOnAndOfflineMapController controller;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final LongPressCallback onLongPress;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, Preference>(
      builder: (context, state) =>
          state.loadOnline ? _buildOnlineMap(state) : _buildOfflineMap(),
    );
  }

  Widget _buildOnlineMap(Preference state) {
    final cfg = TrufiConfiguration();
    return TrufiMap(
      key: const ValueKey("TrufiOnlineMap"),
      controller: controller.online,
      mapOptions: MapOptions(
        minZoom: cfg.map.onlineMinZoom,
        maxZoom: cfg.map.onlineMaxZoom,
        zoom: cfg.map.onlineZoom,
        onTap: onTap,
        onLongPress: onLongPress,
        onPositionChanged: _handleOnPositionChanged,
        center: cfg.map.center,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          tileHostingTileLayerOptions(
            getTilesEndpointForMapType(state.currentMapType),
            tileProviderKey: cfg.map.mapTilerKey,
          ),
          ...layerOptionsBuilder(context),
        ];
      },
    );
  }

  Widget _buildOfflineMap() {
    final cfg = TrufiConfiguration();
    return TrufiMap(
      key: const ValueKey("TrufiOfflineMap"),
      controller: controller.offline,
      mapOptions: MapOptions(
        minZoom: cfg.map.offlineMinZoom,
        maxZoom: cfg.map.offlineMaxZoom,
        zoom: cfg.map.offlineZoom,
        onTap: onTap,
        onPositionChanged: _handleOnPositionChanged,
        swPanBoundary: cfg.map.southWest,
        nePanBoundary: cfg.map.northEast,
        center: cfg.map.center,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          offlineMapTileLayerOptions(),
          ...layerOptionsBuilder(context),
        ];
      },
    );
  }

  void _handleOnPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (onPositionChanged != null) {
      Future.delayed(Duration.zero, () {
        onPositionChanged(position, hasGesture);
      });
    }
  }
}
