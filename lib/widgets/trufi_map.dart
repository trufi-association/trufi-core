import 'dart:async';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/alerts.dart';
import 'package:trufi_app/widgets/trufi_map_animations.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiMapController {
  static const int animationDuration = 500;

  final _mapController = MapController();
  final _mapReadyController = BehaviorSubject<Null>();

  TrufiMapState _state;
  TrufiMapAnimations _animations;

  set state(TrufiMapState state) {
    _state = state;
    _mapController.onReady.then((_) {
      _mapController.move(TrufiMap.cochabambaCenter, 12.0);
      _inMapReady.add(null);
    });
    _animations = TrufiMapAnimations(_mapController);
  }

  void dispose() {
    _mapReadyController.close();
  }

  void moveToYourLocation({
    @required BuildContext context,
    TickerProvider tickerProvider,
  }) async {
    final location = await LocationProviderBloc.of(context).currentLocation;
    if (location != null) {
      move(
        center: location,
        zoom: 17.0,
        tickerProvider: tickerProvider,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  void move({
    @required LatLng center,
    @required double zoom,
    TickerProvider tickerProvider,
  }) {
    if (tickerProvider == null) {
      _mapController.move(center, zoom);
    } else {
      _animations.move(
        center: center,
        zoom: zoom,
        tickerProvider: tickerProvider,
        milliseconds: animationDuration,
      );
    }
  }

  void fitBounds({
    @required LatLngBounds bounds,
    TickerProvider tickerProvider,
  }) {
    if (tickerProvider == null) {
      _mapController.fitBounds(bounds);
    } else {
      _animations.fitBounds(
        bounds: bounds,
        tickerProvider: tickerProvider,
        milliseconds: animationDuration,
      );
    }
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
    final theme = Theme.of(context);
    final locationProviderBloc = LocationProviderBloc.of(context);
    final cfg = GlobalConfiguration();
    final urlMapTiler = cfg.getString("urlMapTiler");
    final urlOpenStreetMap = cfg.getString("urlOpenStreetMap");
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        yourLocationLayer = MarkerLayerOptions(
          markers: snapshot.data != null
              ? <Marker>[buildYourLocationMarker(snapshot.data)]
              : <Marker>[],
        );
        return Stack(children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: widget.controller.mapController,
              options: widget.mapOptions,
              layers: widget.layerOptionsBuilder(context),
            ),
          ),
          Positioned(
            left: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.all(4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      style: theme.textTheme.caption.copyWith(
                        color: Colors.black,
                      ),
                      text: "© MapTiler ",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(urlMapTiler);
                        },
                    ), 
                    TextSpan(
                      style: theme.textTheme.caption.copyWith(
                        color: Colors.black,
                      ),
                      text: "© OpenStreetMap",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(urlOpenStreetMap);
                        },
                    ),
                    TextSpan(
                      style: theme.textTheme.caption.copyWith(
                        color: Colors.black,
                      ),
                      text: " contributors",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
