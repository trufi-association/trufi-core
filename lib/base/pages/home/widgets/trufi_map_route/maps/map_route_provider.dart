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

class MapRouteProvider {
  final ITrufiMapController trufiMapController;
  final MapRouteBuilder mapRouteBuilder;

  const MapRouteProvider({
    required this.trufiMapController,
    required this.mapRouteBuilder,
  });

  factory MapRouteProvider.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
    WidgetBuilder? overlapWidget,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapRouteProvider.leaftletMap(overlapWidget: overlapWidget);
      case TypepProviderMap.googleMap:
        return MapRouteProvider.googleMap(overlapWidget: overlapWidget);
      default:
        throw 'error TypeProviderMap not implement in MapRouteProvider';
    }
  }

  factory MapRouteProvider.googleMap({WidgetBuilder? overlapWidget}) {
    final trufiMapController = TGoogleMapController();
    return MapRouteProvider(
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

  factory MapRouteProvider.leaftletMap({WidgetBuilder? overlapWidget}) {
    final trufiMapController = LeafletMapController();
    return MapRouteProvider(
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
