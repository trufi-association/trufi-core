import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../blocs/preferences_bloc.dart';
import '../composite_subscription.dart';
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
    this.onLongPress,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiOnAndOfflineMapController controller;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final LongPressCallback onLongPress;
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
    final preferencesBloc = PreferencesBloc.of(context);
    final cfg = TrufiConfiguration();
    return StreamBuilder(
      stream: preferencesBloc.outChangeMapType,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TrufiMap(
          key: ValueKey("TrufiOnlineMap"),
          controller: widget.controller.online,
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
                tileProviderKey: cfg.map.mapTilerKey,
              ),
            ]..addAll(widget.layerOptionsBuilder(context));
          },
        );
      },
    );
  }

  Widget _buildOfflineMap() {
    final cfg = TrufiConfiguration();
    return TrufiMap(
      key: ValueKey("TrufiOfflineMap"),
      controller: widget.controller.offline,
      mapOptions: MapOptions(
        minZoom: cfg.map.offlineMinZoom,
        maxZoom: cfg.map.offlineMaxZoom,
        zoom: cfg.map.offlineZoom,
        onTap: widget.onTap,
        onPositionChanged: _handleOnPositionChanged,
        swPanBoundary: cfg.map.southWest,
        nePanBoundary: cfg.map.northEast,
        center: cfg.map.center,
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
