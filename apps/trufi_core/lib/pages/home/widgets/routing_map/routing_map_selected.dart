import 'package:flutter/material.dart';

import 'package:trufi_core/widgets/utils.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class RoutingMapSelected extends TrufiLayer {
  static const String layerId = 'routing-map-selected';
  PlanItinerary? selectedItinerary;

  RoutingMapSelected(super.controller, {required int layerLevel})
    : super(id: layerId, layerLevel: layerLevel + 1);

  void changeItinerary(PlanItinerary? itinerary) {
    selectedItinerary = itinerary;
    _rebuildGraphics();
  }

  void cleanOriginAndDestination() {
    selectedItinerary = null;
    _rebuildGraphics();
  }

  void _rebuildGraphics() {
    setMarkers(_buildMarkers());
    setLines(_buildLines());
  }

  List<TrufiMarker> _buildMarkers() {
    if (selectedItinerary == null) return [];
    return selectedItinerary!.legs
        .where((leg) => leg.transportMode != TransportMode.walk)
        .map((leg) => leg.selectedMarker)
        .toList();
  }

  List<TrufiLine> _buildLines() {
    if (selectedItinerary == null) return [];
    return selectedItinerary!.legs.map((leg) {
      final color = (leg.transportMode == TransportMode.walk)
          ? Colors.black
          : hexToColor(leg.route?.color ?? 'd81b60');
      return TrufiLine(
        id: 'selected-${leg.points}',
        position: leg.accumulatedPoints,
        activeDots: leg.transportMode == TransportMode.walk,
        color: color,
        layerLevel: layerLevel,
        lineWidth: 5,
      );
    }).toList();
  }
}
