import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/maps/utils/trufi_map_animations.dart';
import 'package:trufi_core/base/widgets/maps/utils/trufi_map_utils.dart';

part 'trufi_map_state.dart';

class TrufiMapController extends Cubit<TrufiMapState> {
  final MapController mapController = MapController();

  TrufiMapController() : super(const TrufiMapState());

  Map<Itinerary, List<PolylineWithMarkers>> itineraries = {};
  LatLngBounds? get selectedBounds => _selectedBounds;
  LatLngBounds? _selectedBounds;

  void cleanMap() {
    _selectedBounds = null;
    emit(const TrufiMapState());
  }

  final Completer<Null> readyCompleter = Completer<Null>();

  Future<Null> get onReady => readyCompleter.future;

  Future<void> moveToYourLocation({
    required BuildContext context,
    required LatLng location,
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

  void moveBounds({
    required List<LatLng> points,
    required TickerProvider tickerProvider,
  }) {
    _selectedBounds = LatLngBounds.fromPoints([]);
    for (final point in points) {
      _selectedBounds?.extend(point);
    }
    moveCurrentBounds(tickerProvider: tickerProvider);
  }

  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  }) {
    _fitBounds(
      bounds: _selectedBounds,
      tickerProvider: tickerProvider,
    );
  }

  void selectedItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required TickerProvider tickerProvider,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
  }) {
    _selectedBounds = LatLngBounds(from.latLng, to.latLng);
    // _selectedBounds.extend(from.latLng);
    // _selectedBounds.extend(to.latLng);
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
            _selectedBounds!.extend(marker.point);
          } else {
            _unselectedMarkers.add(marker);
          }
        }
        if (isSelected) {
          _selectedPolylines.add(polylineWithMarker.polyline);
          for (final point in polylineWithMarker.polyline.points) {
            _selectedBounds!.extend(point);
          }
        } else {
          _unselectedPolylines.add(polylineWithMarker.polyline);
        }
        _allPolylines.add(polylineWithMarker.polyline);
      }
    });
    emit(
      state.copyWith(
        unselectedMarkersLayer: MarkerLayer(markers: _unselectedMarkers),
        unselectedPolylinesLayer:
            PolylineLayer(polylines: _unselectedPolylines),
        selectedMarkersLayer: MarkerLayer(markers: _selectedMarkers),
        selectedPolylinesLayer: PolylineLayer(polylines: _selectedPolylines),
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
          final List<LatLng> points = leg.accumulatedPoints.isNotEmpty
              ? leg.accumulatedPoints
              : decodePolyline(leg.points);

          final color = isSelected
              ? leg.transitLeg
                  ? leg.route?.primaryColor ?? leg.transportMode.backgroundColor
                  : leg.transportMode.color
              : Colors.grey;

          final Polyline polyline = Polyline(
            points: points,
            color: color,
            strokeWidth: isSelected ? 6.0 : 3.0,
            pattern: leg.transportMode == TransportMode.walk
                ? StrokePattern.dotted()
                : StrokePattern.solid(),
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

  void move({
    required LatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) {
    if (tickerProvider == null) {
      mapController.move(center, zoom);
    } else {
      TrufiMapAnimations.move(
        center: center,
        zoom: zoom,
        vsync: tickerProvider,
        mapController: mapController,
      );
    }
  }

  void _fitBounds({
    required LatLngBounds? bounds,
    TickerProvider? tickerProvider,
  }) {
    if (bounds == null) return;
    if (tickerProvider == null) {
      mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(50),
      ));
    } else {
      TrufiMapAnimations.fitBounds(
        bounds: bounds,
        vsync: tickerProvider,
        mapController: mapController,
      );
    }
  }
}
