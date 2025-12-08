import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/marker_configuration.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/builders/route_line_builder.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/builders/route_marker_builder.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';

/// Layer for displaying route itineraries.
///
/// Follows the TrufiLayer pattern from trufi_core_maps example.
/// Manages polylines and markers for transit routes.
class RouteLayer extends TrufiLayer {
  static const String layerId = 'route-layer';

  final RouteMarkerBuilder _markerBuilder;
  final RouteLineBuilder _lineBuilder;
  final List<TrufiLatLng> _selectedBoundsPoints = [];

  RouteLayer(
    super.controller, {
    required MarkerConfiguration markerConfiguration,
    ThemeData? themeData,
  })  : _markerBuilder = RouteMarkerBuilder(
          markerConfiguration: markerConfiguration,
          themeData: themeData,
        ),
        _lineBuilder = const RouteLineBuilder(),
        super(id: layerId, layerLevel: 5);

  /// Get the bounds points for the selected itinerary
  List<TrufiLatLng> get selectedBoundsPoints =>
      List.unmodifiable(_selectedBoundsPoints);

  /// Display itineraries on the map
  void selectItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required Itinerary selectedItinerary,
    required Function(Itinerary) onTap,
    Color? walkColor,
  }) {
    clearRoute();

    _selectedBoundsPoints.add(from.latLng);
    _selectedBoundsPoints.add(to.latLng);

    if (plan.itineraries == null) return;

    final selectedLines = <TrufiLine>[];
    final selectedMarkers = <TrufiMarker>[];
    final unselectedLines = <TrufiLine>[];
    final unselectedMarkers = <TrufiMarker>[];

    int lineCounter = 0;
    int markerCounter = 0;

    for (final itinerary in plan.itineraries!) {
      final bool isSelected = itinerary == selectedItinerary;
      final List<Leg> compressedLegs = itinerary.compressLegs;

      // Track alternating colors for primary routes
      bool isPrimary = false;

      for (int i = 0; i < compressedLegs.length; i++) {
        final Leg leg = compressedLegs[i];

        // Get route points
        final List<TrufiLatLng> points = leg.accumulatedPoints.isNotEmpty
            ? leg.accumulatedPoints
            : decodePolyline(leg.points);

        // Determine colors
        Color color = isSelected
            ? leg.transitLeg
                ? leg.backgroundColor
                : leg.transportMode == TransportMode.walk
                    ? (walkColor ?? leg.transportMode.color)
                    : leg.transportMode.color
            : Colors.grey;

        Color textColor = isSelected ? leg.primaryColor : Colors.white;

        if (isSelected && leg.transitLeg && isPrimary) {
          color = Colors.green;
          isPrimary = !isPrimary;
        } else if (isSelected && leg.transitLeg) {
          isPrimary = !isPrimary;
        }

        // Create line
        final line = _lineBuilder.buildLegLine(
          id: 'route-line-${lineCounter++}',
          points: points,
          color: color,
          isSelected: isSelected,
          transportMode: leg.transportMode,
          layerLevel: isSelected ? layerLevel + 1 : layerLevel,
        );

        if (isSelected) {
          selectedLines.add(line);
          for (final point in points) {
            _selectedBoundsPoints.add(point);
          }
        } else {
          unselectedLines.add(line);
        }

        // Transfer marker
        if (isSelected &&
            leg.transitLeg &&
            i < compressedLegs.length - 1 &&
            points.isNotEmpty) {
          selectedMarkers.add(
            _markerBuilder.buildTransferMarker(
              id: 'transfer-marker-${markerCounter++}',
              point: points.first,
              color: color,
              layerLevel: layerLevel + 2,
            ),
          );
          _selectedBoundsPoints.add(points.first);
        }

        // Transport marker (bus number, etc.)
        if (leg.transitLeg) {
          final marker = _markerBuilder.buildTransportMarker(
            id: 'transport-marker-${markerCounter++}',
            point: midPointForPoints(points),
            color: color,
            textColor: textColor,
            leg: leg,
            onTap: () => onTap(itinerary),
            layerLevel: isSelected ? layerLevel + 3 : layerLevel + 2,
          );

          if (isSelected) {
            selectedMarkers.add(marker);
            _selectedBoundsPoints.add(midPointForPoints(points));
          } else {
            unselectedMarkers.add(marker);
          }
        }

        // Intermediate stops
        if (isSelected &&
            leg.intermediatePlaces != null &&
            leg.intermediatePlaces!.isNotEmpty) {
          for (int j = 0; j < leg.intermediatePlaces!.length; j++) {
            final Place stop = leg.intermediatePlaces![j];
            final stopPoint = TrufiLatLng(stop.lat, stop.lon);
            selectedMarkers.add(
              _markerBuilder.buildStopMarker(
                id: 'stop-marker-${markerCounter++}',
                point: stopPoint,
                layerLevel: layerLevel + 2,
              ),
            );
          }
        }
      }
    }

    // Add unselected first (lower layer), then selected on top
    addLines(unselectedLines);
    addMarkers(unselectedMarkers);
    addLines(selectedLines);
    addMarkers(selectedMarkers);
  }

  /// Clear all route data
  void clearRoute() {
    _selectedBoundsPoints.clear();
    clearMarkers();
    clearLines();
  }
}
