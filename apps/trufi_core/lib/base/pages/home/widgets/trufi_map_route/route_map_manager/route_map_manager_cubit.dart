import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';

part 'route_map_manager_state.dart';

class PolylineWithMarkers {
  PolylineWithMarkers(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}

class RouteMapManagerCubit extends Cubit<RouteMapManagerState> {
  RouteMapManagerCubit() : super(const RouteMapManagerState());
  List<TrufiLatLng> _selectedBounds = [];

  void cleanMap() {
    _selectedBounds = [];
    emit(const RouteMapManagerState());
  }

  void selectItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
    required Function(List<TrufiLatLng> bounds) getBounds,
    Color? walkColor,
  }) {
    _selectedBounds = [];
    _selectedBounds.add(from.latLng);
    _selectedBounds.add(to.latLng);
    final itineraries = _buildItineraries(
      plan: plan,
      selectedItinerary: selectedItinerary,
      onTap: onTap,
      walkColor: walkColor,
    );
    final unselectedMarkers = <Marker>[];
    final unselectedPolylines = <Polyline>[];
    final selectedMarkers = <Marker>[];
    final selectedPolylines = <Polyline>[];
    itineraries.forEach((itinerary, polylinesWithMarker) {
      final bool isSelected = itinerary == selectedItinerary;
      for (final polylineWithMarker in polylinesWithMarker) {
        for (final marker in polylineWithMarker.markers) {
          if (isSelected) {
            selectedMarkers.add(marker);
            _selectedBounds.add(TrufiLatLng.fromLatLng(marker.point));
          } else {
            unselectedMarkers.add(marker);
          }
        }
        if (isSelected) {
          selectedPolylines.add(polylineWithMarker.polyline);
          for (final point in polylineWithMarker.polyline.points) {
            _selectedBounds.add(TrufiLatLng.fromLatLng(point));
          }
        } else {
          unselectedPolylines.add(polylineWithMarker.polyline);
        }
      }
    });
    emit(
      state.copyWith(
        unselectedMarkersLayer: MarkerLayer(markers: unselectedMarkers),
        unselectedPolylinesLayer: PolylineLayer(polylines: unselectedPolylines),
        selectedMarkersLayer: MarkerLayer(markers: selectedMarkers),
        selectedPolylinesLayer: PolylineLayer(polylines: selectedPolylines),
      ),
    );
    getBounds(_selectedBounds);
  }

  Map<Itinerary, List<PolylineWithMarkers>> _buildItineraries({
    required Plan plan,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
    Color? walkColor,
  }) {
    Map<Itinerary, List<PolylineWithMarkers>> itineraries = {};
    if (plan.itineraries != null) {
      for (final itinerary in plan.itineraries!) {
        final List<Marker> markers = [];
        final List<PolylineWithMarkers> polylinesWithMarkers = [];
        final bool isSelected = itinerary == selectedItinerary;

        final List<Leg> compressedLegs = itinerary.compressLegs;

        // TODO Implement a boolean to configure if the backend has a server or not
        // Implement for otpServer without route color configuration
        bool isPrimary = false;

        for (int i = 0; i < compressedLegs.length; i++) {
          final Leg leg = compressedLegs[i];
          // Polyline
          final List<TrufiLatLng> points = leg.accumulatedPoints.isNotEmpty
              ? leg.accumulatedPoints
              : decodePolyline(leg.points);

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

          final Polyline polyline = Polyline(
            points: TrufiLatLng.toListLatLng(points),
            color: color,
            strokeWidth: isSelected ? 6.0 : 3.0,
            pattern: leg.transportMode == TransportMode.walk
                ? StrokePattern.dotted()
                : StrokePattern.solid(),
          );

          // Transfer marker
          if (isSelected &&
              leg.transitLeg &&
              i < compressedLegs.length - 1 &&
              points.isNotEmpty) {
            markers.add(
              buildTransferMarker(
                point: points.first,
                color: color,
              ),
            );
          }

          // Bus marker
          if (leg.transitLeg) {
            markers.add(
              buildTransportMarker(
                midPointForPoints(points),
                color,
                textColor,
                leg,
                onTap: () => onTap(itinerary),
              ),
            );
          }

          if (isSelected &&
              leg.intermediatePlaces != null &&
              leg.intermediatePlaces!.isNotEmpty) {
            for (Place stop in leg.intermediatePlaces!) {
              markers.add(
                buildStopMarker(TrufiLatLng(stop.lat, stop.lon)),
              );
            }
          }
          polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
        }

        itineraries.addAll({itinerary: polylinesWithMarkers});
      }
    }
    return itineraries;
  }
}
