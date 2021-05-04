import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

import '../../blocs/gps_location/location_provider_cubit.dart';
import '../../trufi_configuration.dart';
import '../../widgets/alerts.dart';
import '../../widgets/trufi_map_animations.dart';
typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiMapController {
  static const int animationDuration = 500;

  final _mapController = MapController();
  final _mapReadyController = BehaviorSubject<void>();
TrufiMapController(){
    _mapController.onReady.then((_) {
      log("onReady");
      final cfg = TrufiConfiguration();
      final zoom = cfg.map.defaultZoom;
      final mapCenter = cfg.map.center;

      _mapController.move(mapCenter, zoom);
      _inMapReady.add(null);
    });
    _animations = TrufiMapAnimations(_mapController);
}
  // TrufiMapState _state;
  TrufiMapAnimations _animations;

  // void setState(TrufiMapState state) {
  //   // _state = state;
  //   _mapController.onReady.then((_) {
  //     log("onReady");
  //     final cfg = TrufiConfiguration();
  //     final zoom = cfg.map.defaultZoom;
  //     final mapCenter = cfg.map.center;

  //     _mapController.move(mapCenter, zoom);
  //     _inMapReady.add(null);
  //   });
  //   _animations = TrufiMapAnimations(_mapController);
  // }

  void dispose() {
    _mapReadyController.close();
  }

  Future<void> moveToYourLocation({
    @required BuildContext context,
    @required LatLng location,
    TickerProvider tickerProvider,
  }) async {
    final cfg = TrufiConfiguration();
    final zoom = cfg.map.chooseLocationZoom;

    if (location != null) {
      move(
        center: location,
        zoom: zoom,
        tickerProvider: tickerProvider,
      );
      context.read<LocationProviderCubit>().start();
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

  Sink<void> get _inMapReady => _mapReadyController.sink;

  Stream<void> get outMapReady => _mapReadyController.stream;

  MapController get mapController => _mapController;

  // LayerOptions get yourLocationLayer => _state.yourLocationLayer;
}

