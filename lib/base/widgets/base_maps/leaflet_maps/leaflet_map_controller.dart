// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';
import 'package:trufi_core/base/models/map_provider/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/trufi_map_animations.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';

part 'leaflet_map_state.dart';

class PolylineWithMarkers {
  PolylineWithMarkers(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}

class LeafletMapController extends Cubit<LeafletMapState>
    implements ITrufiMapController {
  static const int animationDuration = 500;
  MapController? mapController;

  LeafletMapController() : super(const LeafletMapState());

  final TrufiMapAnimations _animations = TrufiMapAnimations();
  Map<Itinerary, List<PolylineWithMarkers>> itineraries = {};
  LatLngBounds get selectedBounds => _selectedBounds;
  LatLngBounds _selectedBounds = LatLngBounds();

  final Completer<Null> readyCompleter = Completer<Null>();
  
  @override
  Future<Null> get onReady => readyCompleter.future;

  @override
  void cleanMap() {
    _selectedBounds = LatLngBounds();
    emit(const LeafletMapState());
  }

  @override
  Future<void> moveToYourLocation({
    required BuildContext context,
    required TrufiLatLng location,
    required double zoom,
    TickerProvider? tickerProvider,
  }) async {
    move(
      center: location,
      zoom: zoom,
      tickerProvider: tickerProvider,
    );
    return;
  }

  @override
  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  }) {
    _selectedBounds = LatLngBounds();
    for (final point in points) {
      _selectedBounds.extend(point.toLatLng());
    }
    _fitBounds(bounds: _selectedBounds, tickerProvider: tickerProvider);
  }

  @override
  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  }) {
    _fitBounds(
      bounds: _selectedBounds,
      tickerProvider: tickerProvider,
    );
  }

  @override
  void selectedItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required TickerProvider tickerProvider,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
  }) {
    _selectedBounds = LatLngBounds();
    _selectedBounds.extend(from.latLng.toLatLng());
    _selectedBounds.extend(to.latLng.toLatLng());
    final itineraries = _buildItineraries(
      plan: plan,
      selectedItinerary: selectedItinerary,
      onTap: onTap,
    );
    final _unselectedMarkers = <Marker>[];
    final _unselectedPolylines = <Polyline>[];
    final _selectedMarkers = <Marker>[];
    final _selectedPolylines = <Polyline>[];
    final _allPolylines = <Polyline>[];
    itineraries.forEach((itinerary, polylinesWithMarker) {
      final bool isSelected = itinerary == selectedItinerary;
      for (final polylineWithMarker in polylinesWithMarker) {
        for (final marker in polylineWithMarker.markers) {
          if (isSelected) {
            _selectedMarkers.add(marker);
            _selectedBounds.extend(marker.point);
          } else {
            _unselectedMarkers.add(marker);
          }
        }
        if (isSelected) {
          _selectedPolylines.add(polylineWithMarker.polyline);
          for (final point in polylineWithMarker.polyline.points) {
            _selectedBounds.extend(point);
          }
        } else {
          _unselectedPolylines.add(polylineWithMarker.polyline);
        }
        _allPolylines.add(polylineWithMarker.polyline);
      }
    });
    emit(
      state.copyWith(
        unselectedMarkersLayer: MarkerLayerOptions(markers: _unselectedMarkers),
        unselectedPolylinesLayer:
            PolylineLayerOptions(polylines: _unselectedPolylines),
        selectedMarkersLayer: MarkerLayerOptions(markers: _selectedMarkers),
        selectedPolylinesLayer:
            PolylineLayerOptions(polylines: _selectedPolylines),
      ),
    );
    moveCurrentBounds(tickerProvider: tickerProvider);
  }

  Map<Itinerary, List<PolylineWithMarkers>> _buildItineraries({
    required Plan plan,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
  }) {
    itineraries = {};
    if (plan.itineraries != null) {
      for (final itinerary in plan.itineraries!) {
        final List<Marker> markers = [];
        final List<PolylineWithMarkers> polylinesWithMarkers = [];
        final bool isSelected = itinerary == selectedItinerary;

        final List<Leg> compressedLegs = itinerary.compressLegs;
        for (int i = 0; i < compressedLegs.length; i++) {
          final Leg leg = compressedLegs[i];
          // Polyline
          final List<TrufiLatLng> points = leg.accumulatedPoints.isNotEmpty
              ? leg.accumulatedPoints
              : decodePolyline(leg.points);

          final color = isSelected
              ? leg.transitLeg
                  ? leg.route?.primaryColor ?? leg.transportMode.backgroundColor
                  : leg.transportMode.color
              : Colors.grey;

          final Polyline polyline = Polyline(
            points: TrufiLatLng.toListLatLng(points),
            color: color,
            strokeWidth: isSelected ? 6.0 : 3.0,
            isDotted: leg.transportMode == TransportMode.walk,
          );

          // Transfer marker
          if (isSelected &&
              i < compressedLegs.length - 1 &&
              points.isNotEmpty) {
            markers.add(
              buildTransferMarker(
                points[points.length - 1],
              ),
            );
          }

          // Bus marker
          if (leg.transitLeg) {
            markers.add(
              buildTransportMarker(
                midPointForPoints(points),
                color,
                leg,
                onTap: () => onTap(itinerary),
              ),
            );
          }
          polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
        }

        itineraries.addAll({itinerary: polylinesWithMarkers});
      }
    }
    return itineraries;
  }

  @override
  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) {
    if (tickerProvider == null) {
      mapController?.move(center.toLatLng(), zoom);
    } else if (mapController != null) {
      _animations.move(
        center: center.toLatLng(),
        zoom: zoom,
        tickerProvider: tickerProvider,
        milliseconds: animationDuration,
        mapController: mapController!,
      );
    }
  }

  void _fitBounds({
    required LatLngBounds bounds,
    TickerProvider? tickerProvider,
  }) {
    if (tickerProvider == null) {
      mapController?.fitBounds(bounds);
    } else if (mapController != null) {
      _animations.fitBounds(
        bounds: bounds,
        tickerProvider: tickerProvider,
        milliseconds: animationDuration,
        mapController: mapController!,
      );
    }
  }
}
