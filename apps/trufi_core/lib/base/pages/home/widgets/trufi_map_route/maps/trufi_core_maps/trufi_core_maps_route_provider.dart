import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/trufi_core_maps/trufi_core_maps_route.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_controller.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Provider for TrufiCoreMapsRoute widget.
///
/// Implements MapRouteProvider using the TrufiLayer architecture.
/// Supports any map engine that implements ITrufiMapEngine.
class TrufiCoreMapsRouteProvider implements MapRouteProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapRouteBuilder mapRouteBuilder;

  const TrufiCoreMapsRouteProvider({
    required this.trufiMapController,
    required this.mapRouteBuilder,
  });

  /// Create a provider with a specific map engine
  factory TrufiCoreMapsRouteProvider.create({
    required ITrufiMapEngine mapEngine,
    List<ITrufiMapEngine>? availableEngines,
    Uri? shareBaseItineraryUri,
    WidgetBuilder? overlapWidget,
  }) {
    // Use a temporary position - the widget will move to the configured center
    final controller = TrufiCoreMapsController(
      initialCameraPosition: const TrufiCameraPosition(
        target: latlng.LatLng(0, 0),
        zoom: 2.0,
      ),
    );

    return TrufiCoreMapsRouteProvider(
      trufiMapController: controller,
      mapRouteBuilder: (mapContext, asyncExecutor) {
        return TrufiCoreMapsRoute(
          trufiMapController: controller,
          asyncExecutor: asyncExecutor,
          shareBaseItineraryUri: shareBaseItineraryUri,
          overlapWidget: overlapWidget,
          mapEngine: mapEngine,
          availableEngines: availableEngines ?? [mapEngine],
        );
      },
    );
  }
}
