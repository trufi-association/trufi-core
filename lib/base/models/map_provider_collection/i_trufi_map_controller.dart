// ignore_for_file: prefer_void_to_null

import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

abstract class ITrufiMapController {
  Future<Null> get onReady;
  void cleanMap();
  Future<void> moveToYourLocation({
    required BuildContext context,
    required TrufiLatLng location,
    required double zoom,
    TickerProvider? tickerProvider,
  });

  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  });

  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  });

  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  });
}
