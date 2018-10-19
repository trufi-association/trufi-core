import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/alerts.dart';

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

class TrufiMapController {
  final _mapController = MapController();
  final _mapReadyController = BehaviorSubject<Null>();

  TrufiMapState _state;

  set state(TrufiMapState state) {
    _state = state;
    _mapController.onReady.then((_) {
      _mapController.move(TrufiMap.cochabambaCenter, 12.0);
      _inMapReady.add(null);
    });
  }

  void dispose() {
    _mapReadyController.close();
  }

  void moveToYourLocation(BuildContext context) async {
    final locationProviderBloc = LocationProviderBloc.of(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _mapController.move(lastLocation, 17.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  Sink<Null> get _inMapReady => _mapReadyController.sink;

  Stream<Null> get outMapReady => _mapReadyController.stream;

  MapController get mapController => _mapController;

  LayerOptions get yourLocationLayer => _state.yourLocationLayer;
}

class TrufiMap extends StatefulWidget {
  static final LatLng cochabambaCenter = LatLng(-17.39000, -66.15400);
  static final LatLng cochabambaSouthWest = LatLng(-17.79300, -66.75000);
  static final LatLng cochabambaNorthEast = LatLng(-16.90400, -65.67400);

  TrufiMap({
    Key key,
    @required this.controller,
    @required this.mapOptions,
    @required this.layerOptionsBuilder,
  }) : super(key: key);

  final TrufiMapController controller;
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
    widget.controller.state = this;
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
          mapController: widget.controller.mapController,
          options: widget.mapOptions,
          layers: widget.layerOptionsBuilder(context),
        );
      },
    );
  }
}
