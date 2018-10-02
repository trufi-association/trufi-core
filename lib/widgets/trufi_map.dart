import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiOnlineMapController {
  TrufiOnlineMapState state;

  void setState(TrufiOnlineMapState state) {
    this.state = state;
  }

  void fitBounds(
    LatLngBounds bounds, {
    FitBoundsOptions options,
  }) {
    state.mapController.fitBounds(bounds, options: options);
  }

  void move(LatLng center, double zoom) {
    state.mapController.move(center, zoom);
  }

  bool get ready {
    return state.mapController.ready;
  }
}

class TrufiOnlineMap extends StatefulWidget {
  TrufiOnlineMap({
    @required this.mapController,
    @required this.layerOptionsBuilder,
    this.initialPosition,
    this.onTap,
    this.onPositionChanged,
  });

  final TrufiOnlineMapController mapController;
  final LayerOptionsBuilder layerOptionsBuilder;
  final LatLng initialPosition;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiOnlineMapState createState() => TrufiOnlineMapState();
}

class TrufiOnlineMapState extends State<TrufiOnlineMap> {
  final _offlineTrufiMapController = TrufiMapController();
  final _onlineTrufiMapController = TrufiMapController();

  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    widget.mapController.setState(this);
  }

  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    return StreamBuilder<bool>(
      stream: preferencesBloc.outChangeOnline,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshotOnline,
      ) {
        isOnline = snapshotOnline.data == true;
        return isOnline
            ? TrufiMap(
                key: ValueKey("TrufiOnlineMap"),
                trufiMapController: _onlineTrufiMapController,
                mapOptions: MapOptions(
                  minZoom: 1.0,
                  maxZoom: 19.0,
                  zoom: 13.0,
                  onTap: widget.onTap,
                  onPositionChanged: widget.onPositionChanged,
                  center: TrufiMap.cochabambaCenter,
                ),
                layerOptionsBuilder: (context) {
                  return <LayerOptions>[
                    tileHostingTileLayerOptions(),
                  ]..addAll(widget.layerOptionsBuilder(context));
                },
                initialPosition: widget.initialPosition,
              )
            : TrufiMap(
                key: ValueKey("TrufiOfflineMap"),
                trufiMapController: _offlineTrufiMapController,
                mapOptions: MapOptions(
                  minZoom: 8.0,
                  maxZoom: 14.0,
                  zoom: 13.0,
                  onTap: widget.onTap,
                  onPositionChanged: widget.onPositionChanged,
                  swPanBoundary: TrufiMap.cochabambaSouthWest,
                  nePanBoundary: TrufiMap.cochabambaNorthEast,
                  center: TrufiMap.cochabambaCenter,
                ),
                layerOptionsBuilder: (context) {
                  return <LayerOptions>[
                    offlineMapTileLayerOptions(),
                  ]..addAll(widget.layerOptionsBuilder(context));
                },
                initialPosition: widget.initialPosition,
              );
      },
    );
  }

  MapController get mapController {
    return isOnline
        ? _onlineTrufiMapController.state.mapController
        : _offlineTrufiMapController.state.mapController;
  }

  LayerOptions get yourLocationLayer {
    return isOnline
        ? _onlineTrufiMapController.state.yourLocationLayer
        : _offlineTrufiMapController.state.yourLocationLayer;
  }
}

class TrufiMapController {
  TrufiMapState state;

  void setState(TrufiMapState state) {
    this.state = state;
  }
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
    this.initialPosition,
    this.onTap,
    this.onPositionChanged,
  }) : super(key: key);

  final TrufiMapController trufiMapController;
  final MapOptions mapOptions;
  final LayerOptionsBuilder layerOptionsBuilder;
  final LatLng initialPosition;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  final MapController mapController = MapController();

  LayerOptions yourLocationLayer;

  @override
  void initState() {
    super.initState();
    widget.trufiMapController.setState(this);
    mapController.onReady.then((_) {
      mapController.move(
        widget.initialPosition != null
            ? widget.initialPosition
            : TrufiMap.cochabambaCenter,
        12.0,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (
        BuildContext context,
        AsyncSnapshot<LatLng> snapshotLocation,
      ) {
        yourLocationLayer = MarkerLayerOptions(
          markers: snapshotLocation.data != null
              ? <Marker>[buildYourLocationMarker(snapshotLocation.data)]
              : <Marker>[],
        );
        return FlutterMap(
          mapController: mapController,
          options: widget.mapOptions,
          layers: widget.layerOptionsBuilder(context),
        );
      },
    );
  }
}
