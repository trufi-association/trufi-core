import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/google_map_route.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/leaflet_map_route.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapRouteBuilder = Widget Function(
  BuildContext,
  AsyncExecutor asyncExecutor,
);

abstract class MapRouteProvider {
  ITrufiMapController get trufiMapController;
  MapRouteBuilder get mapRouteBuilder;
}

class MapRouteProviderImplementation implements MapRouteProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapRouteBuilder mapRouteBuilder;

  const MapRouteProviderImplementation({
    required this.trufiMapController,
    required this.mapRouteBuilder,
  });

  factory MapRouteProviderImplementation.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
    WidgetBuilder? overlapWidget,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.leafletMap:
        return MapRouteProviderImplementation.leafletMap(
            overlapWidget: overlapWidget);
      case TypepProviderMap.googleMap:
        return MapRouteProviderImplementation.googleMap(
            overlapWidget: overlapWidget);
      default:
        throw 'error TypeProviderMap not implement in MapRouteProvider';
    }
  }

  factory MapRouteProviderImplementation.googleMap(
      {WidgetBuilder? overlapWidget}) {
    final trufiMapController = TGoogleMapController();
    return MapRouteProviderImplementation(
      trufiMapController: trufiMapController,
      mapRouteBuilder: (mapContext, asyncExecutor) {
        return TGoogleMapRoute(
          trufiMapController: trufiMapController,
          asyncExecutor: asyncExecutor,
          overlapWidget: overlapWidget,
        );
      },
    );
  }

  factory MapRouteProviderImplementation.leafletMap(
      {WidgetBuilder? overlapWidget}) {
    final trufiMapController = LeafletMapController();
    return MapRouteProviderImplementation(
      trufiMapController: trufiMapController,
      mapRouteBuilder: (mapContext, asyncExecutor) {
        return LeafletMapRoute(
          trufiMapController: trufiMapController,
          asyncExecutor: asyncExecutor,
          overlapWidget: overlapWidget,
        );
      },
    );
  }
}
