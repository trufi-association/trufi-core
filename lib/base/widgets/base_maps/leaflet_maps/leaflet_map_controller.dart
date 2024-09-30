import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/trufi_map_animations.dart';

class LeafletMapController implements ITrufiMapController {
  static const int animationDuration = 500;
  MapController mapController = MapController();
  LeafletMapController() : super();

  LatLngBounds? get selectedBounds => _selectedBounds;
  LatLngBounds? _selectedBounds;
  // ignore: prefer_void_to_null
  final Completer<Null> readyCompleter = Completer<Null>();

  @override
  // ignore: prefer_void_to_null
  Future<Null> get onReady => readyCompleter.future;

  @override
  void cleanMap() {
    _selectedBounds = null;
  }

  @override
  Future<void> moveToYourLocation({
    required BuildContext context,
    required TrufiLatLng location,
    required double zoom,
    TickerProvider? tickerProvider,
  }) async {
    move(
      center: location,
      zoom: zoom,
      tickerProvider: tickerProvider,
    );
    return;
  }

  @override
  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  }) {
    _selectedBounds = LatLngBounds(
      points.first.toLatLng(),
      points.last.toLatLng(),
    );
    for (final point in points) {
      _selectedBounds!.extend(point.toLatLng());
    }
    _fitBounds(bounds: _selectedBounds, tickerProvider: tickerProvider);
  }

  @override
  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  }) {
    _fitBounds(
      bounds: _selectedBounds,
      tickerProvider: tickerProvider,
    );
  }

  @override
  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) {
    if (tickerProvider == null) {
      mapController.move(center.toLatLng(), zoom);
    } else {
      TrufiMapAnimations.move(
        center: center.toLatLng(),
        zoom: zoom,
        vsync: tickerProvider,
        mapController: mapController,
      );
    }
  }

  void _fitBounds({
    required LatLngBounds? bounds,
    TickerProvider? tickerProvider,
  }) {
    if (bounds == null) return;
    if (tickerProvider == null) {
      mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(50),
      ));
    } else {
      TrufiMapAnimations.fitBounds(
        bounds: bounds,
        vsync: tickerProvider,
        mapController: mapController,
      );
    }
  }
}
