import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';

import '../../blocs/gps_location/location_provider_cubit.dart';
import '../../widgets/alerts.dart';
import '../../widgets/trufi_map_animations.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiMapController {
  static const int animationDuration = 500;

  final _mapController = MapController();
  final _mapReadyController = BehaviorSubject<void>();

  TrufiMapController() {
    _animations = TrufiMapAnimations(_mapController);
  }

  TrufiMapAnimations _animations;

  void dispose() {
    _mapReadyController.close();
  }

  Future<void> moveToYourLocation({
    @required BuildContext context,
    @required LatLng location,
    TickerProvider tickerProvider,
  }) async {
    final cfg = context.read<ConfigurationCubit>().state;
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

  Sink<void> get inMapReady => _mapReadyController.sink;

  Stream<void> get outMapReady => _mapReadyController.stream;

  MapController get mapController => _mapController;
}
