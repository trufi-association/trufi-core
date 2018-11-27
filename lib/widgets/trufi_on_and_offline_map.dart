import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

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
  final _mapReadyController = BehaviorSubject<Null>();

  TrufiOnAndOfflineMapState _state;

  set state(TrufiOnAndOfflineMapState state) {
    _state = state;
  }

  void dispose() {
    _offlineController.dispose();
    _onlineController.dispose();
    _mapReadyController.close();
  }

  void moveToYourLocation(BuildContext context) {
    active.moveToYourLocation(context);
  }

  void move(LatLng center, double zoom) {
    active.move(center, zoom);
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
    return TrufiMap(
      key: ValueKey("TrufiOnlineMap"),
      controller: widget.controller.online,
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

  Widget _buildOfflineMap() {
    return TrufiMap(
      key: ValueKey("TrufiOfflineMap"),
      controller: widget.controller.offline,
      mapOptions: MapOptions(
        minZoom: 8.0,
        maxZoom: 14.0,
        zoom: 13.0,
        onTap: widget.onTap,
        onPositionChanged: _handleOnPositionChanged,
        swPanBoundary: TrufiMap.cochabambaSouthWest,
        nePanBoundary: TrufiMap.cochabambaNorthEast,
        center: TrufiMap.cochabambaCenter,
      ),
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          offlineMapTileLayerOptions(),
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

  // Getter

  bool get isOnline => _online;
}