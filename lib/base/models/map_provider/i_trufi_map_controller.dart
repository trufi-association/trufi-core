// ignore_for_file: prefer_void_to_null

import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

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

  void selectedItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required TickerProvider tickerProvider,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
  });

  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  });
}
