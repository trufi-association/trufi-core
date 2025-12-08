import 'package:flutter/material.dart';
import '../models/trufi_latlng.dart';

/// Interface for map engines (MapLibre, FlutterMap, etc).
///
/// Implement this interface to create custom map engines that can be
/// used with trufi_core map providers.
abstract class ITrufiMapEngine {
  /// Unique identifier for this engine
  String get id;

  /// Display name for UI
  String get name;

  /// Optional description
  String get description;

  /// Build the map widget
  Widget buildMap({
    required dynamic controller,
    void Function(TrufiLatLng)? onMapClick,
    void Function(TrufiLatLng)? onMapLongClick,
  });
}

/// Interface for map controller operations.
abstract class ITrufiMapController {
  /// Move the map to a specific location
  void move({
    required TrufiLatLng center,
    required double zoom,
    required TickerProvider tickerProvider,
  });

  /// Move the map to fit bounds containing all points
  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  });

  /// Move to current bounds (crop)
  void moveCurrentBounds({required TickerProvider tickerProvider});

  /// Clean the map (remove markers, routes, etc)
  void cleanMap();
}
