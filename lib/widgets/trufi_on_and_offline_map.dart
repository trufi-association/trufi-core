import 'dart:async';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart' as rx;

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnAndOfflineMapController {
  TrufiOnAndOfflineMapController() {
    _offlineController.outMapReady.listen((_) => _inMapReady.add(null));
    _onlineController.outMapReady.listen((_) => _inMapReady.add(null));
  }

  final _offlineController = TrufiMapController();
  final _onlineController = TrufiMapController();
  final _mapReadyController = rx.BehaviorSubject<Null>();

  TrufiOnAndOfflineMapState _state;

  set state(TrufiOnAndOfflineMapState state) {
    _state = state;
  }

  void dispose() {
    _offlineController.dispose();
    _onlineController.dispose();
    _mapReadyController.close();
  }

  void moveToYourLocation(BuildContext context, TickerProvider tickerProvider) {
    active.moveToYourLocation(context: context, tickerProvider: tickerProvider);
  }

  void move(LatLng center, double zoom, TickerProvider tickerProvider) {
    active.move(
      center: center,
      zoom: zoom,
      tickerProvider: tickerProvider,
    );
  }

  Sink<Null> get _inMapReady => _mapReadyController.sink;

  Stream<Null> get outMapReady => _mapReadyController.stream;

  TrufiMapController get offline => _offlineController;

  TrufiMapController get online => _onlineController;

  TrufiMapController get active => _isOnline ? online : offline;

  MapController get mapController => active.mapController;

  LayerOptions get yourLocationLayer => active.yourLocationLayer;

  bool get _isOnline => _state?.isOnline ?? false;
}

class TrufiOnAndOfflineMap extends StatefulWidget {
  TrufiOnAndOfflineMap({
    Key key,
    @required this.controller,
    @required this.layerOptionsBuilder,
    this.onTap,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiOnAndOfflineMapController controller;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiOnAndOfflineMapState createState() => TrufiOnAndOfflineMapState();
}

class TrufiOnAndOfflineMapState extends State<TrufiOnAndOfflineMap> {
  final _subscriptions = CompositeSubscription();

  bool _online = false;

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
    _subscriptions.add(
      PreferencesBloc.of(context).outChangeOnline.listen((online) {
        setState(() {
          _online = online;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _online ? _buildOnlineMap() : _buildOfflineMap();
  }

  Widget _buildOnlineMap() {
    final cfg = GlobalConfiguration();
    final minZoom = cfg.getDouble("mapOnlineMinZoom");
    final maxZoom = cfg.getDouble("mapOnlineMaxZoom");
    final zoom = cfg.getDouble("mapOnlineZoom");
    final centerCoords = List<double>.from(cfg.get("mapCenterCoordsLatLng"));
    final mapCenter = LatLng(centerCoords[0], centerCoords[1]);

    return TrufiMap(
      key: ValueKey("TrufiOnlineMap"),
      controller: widget.controller.online,
      mapOptions: MapOptions(
        minZoom: minZoom,
        maxZoom: maxZoom,
        zoom: zoom,
        onTap: widget.onTap,
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

  Widget _buildOfflineMap() {
    final cfg = GlobalConfiguration();
    final minZoom = cfg.getDouble("mapOfflineMinZoom");
    final maxZoom = cfg.getDouble("mapOfflineMaxZoom");
    final zoom = cfg.getDouble("mapOfflineZoom");
    final southWestCoords = List<double>.from(cfg.get("mapSouthWestCoordsLatLng"));
    final northEastCoords = List<double>.from(cfg.get("mapNorthEastCoordsLatLng"));
    final centerCoords = List<double>.from(cfg.get("mapCenterCoordsLatLng"));
    final mapSouthWest = LatLng(southWestCoords[0], southWestCoords[1]);
    final mapNorthEast = LatLng(northEastCoords[0], northEastCoords[1]);
    final mapCenter = LatLng(centerCoords[0], centerCoords[1]);

    return TrufiMap(
      key: ValueKey("TrufiOfflineMap"),
      controller: widget.controller.offline,
      mapOptions: MapOptions(
        minZoom: minZoom,
        maxZoom: maxZoom,
        zoom: zoom,
        onTap: widget.onTap,
        onPositionChanged: _handleOnPositionChanged,
        swPanBoundary: mapSouthWest,
        nePanBoundary: mapNorthEast,
        center: mapCenter,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          offlineMapTileLayerOptions(),
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

  // Getter

  bool get isOnline => _online;
}
