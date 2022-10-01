import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';

import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/leaflet_map_route.dart';
import 'package:trufi_core/base/models/map_provider/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

class LeafletMapRouteProvider implements MapRouteProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapRouteBuilder mapRouteBuilder;

  const LeafletMapRouteProvider({
    required this.trufiMapController,
    required this.mapRouteBuilder,
  });

  factory LeafletMapRouteProvider.create({
    Uri? shareBaseItineraryUri,
    WidgetBuilder? overlapWidget,
  }) {
    final trufiMapController = LeafletMapController();
    return LeafletMapRouteProvider(
      trufiMapController: trufiMapController,
      mapRouteBuilder: (mapContext, asyncExecutor) {
        return LeafletMapRoute(
          trufiMapController: trufiMapController,
          asyncExecutor: asyncExecutor,
          shareBaseItineraryUri: shareBaseItineraryUri,
          overlapWidget: overlapWidget,
        );
      },
    );
  }
}
