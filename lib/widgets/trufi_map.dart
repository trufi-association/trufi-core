import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_map_utils.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnlineMapController {
  TrufiOnlineMapController() {
    _offlineTrufiMapController.outMapReady.listen((_) => _inMapReady.add(null));
    _onlineTrufiMapController.outMapReady.listen((_) => _inMapReady.add(null));
  }

  final _offlineTrufiMapController = TrufiMapController();
  final _onlineTrufiMapController = TrufiMapController();
  final _mapReadyController = new BehaviorSubject<Null>();

  TrufiOnlineMapState _state;

  void dispose() {
    _offlineTrufiMapController.dispose();
    _onlineTrufiMapController.dispose();
    _mapReadyController.close();
  }

  set state(TrufiOnlineMapState state) {
    _state = state;
  }

  Sink<Null> get _inMapReady => _mapReadyController.sink;

  Stream<Null> get outMapReady => _mapReadyController.stream;

  TrufiMapController get offline => _offlineTrufiMapController;

  TrufiMapController get online => _onlineTrufiMapController;

  TrufiMapController get active => _isOnline ? online : offline;

  MapController get mapController => active.mapController;

  LayerOptions get yourLocationLayer => active.yourLocationLayer;

  bool get _isOnline => _state?.isOnline ?? false;
}

class TrufiOnlineMap extends StatefulWidget {
  TrufiOnlineMap({
    Key key,
    @required this.trufiOnlineMapController,
    @required this.layerOptionsBuilder,
    this.onTap,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiOnlineMapController trufiOnlineMapController;
  final LayerOptionsBuilder layerOptionsBuilder;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiOnlineMapState createState() => TrufiOnlineMapState();
}

class TrufiOnlineMapState extends State<TrufiOnlineMap> {
  final _subscriptions = CompositeSubscription();

  bool _online = false;

  @override
  void initState() {
    super.initState();
    widget.trufiOnlineMapController.state = this;
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
    return _online
        ? TrufiMap(
            key: ValueKey("TrufiOnlineMap"),
            trufiMapController: widget.trufiOnlineMapController.online,
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
          )
        : TrufiMap(
            key: ValueKey("TrufiOfflineMap"),
            trufiMapController: widget.trufiOnlineMapController.offline,
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

class TrufiMapController {
  final _mapController = MapController();

  TrufiMapState _state;
  BehaviorSubject<Null> _mapReadyController = new BehaviorSubject<Null>();

  void dispose() {
    _mapReadyController.close();
  }

  set state(TrufiMapState state) {
    _state = state;
    _mapController.onReady.then((_) {
      _mapController.move(TrufiMap.cochabambaCenter, 12.0);
      _inMapReady.add(null);
    });
  }

  Sink<Null> get _inMapReady => _mapReadyController.sink;

  Stream<Null> get outMapReady => _mapReadyController.stream;

  MapController get mapController => _mapController;

  LayerOptions get yourLocationLayer => _state.yourLocationLayer;
}

class TrufiMap extends StatefulWidget {
  static final LatLng cochabambaCenter = LatLng(-17.3940469, -66.233916);
  static final LatLng cochabambaSouthWest = LatLng(-17.79300, -66.75000);
  static final LatLng cochabambaNorthEast = LatLng(-16.90400, -65.67400);

  TrufiMap({
    Key key,
    @required this.trufiMapController,
    @required this.mapOptions,
    @required this.layerOptionsBuilder,
  }) : super(key: key);

  final TrufiMapController trufiMapController;
  final MapOptions mapOptions;
  final LayerOptionsBuilder layerOptionsBuilder;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  LayerOptions yourLocationLayer;

  @override
  void initState() {
    super.initState();
    widget.trufiMapController.state = this;
  }

  @override
  Widget build(BuildContext context) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        yourLocationLayer = MarkerLayerOptions(
          markers: snapshot.data != null
              ? <Marker>[buildYourLocationMarker(snapshot.data)]
              : <Marker>[],
        );
        return FlutterMap(
          mapController: widget.trufiMapController.mapController,
          options: widget.mapOptions,
          layers: widget.layerOptionsBuilder(context),
        );
      },
    );
  }
}
