import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';

part 'google_map_state.dart';

class TGoogleMapController extends Cubit<GoogleMapState>
    implements ITrufiMapController {
  static const defaultCameraPosition = CameraPosition(
    target: LatLng(-17.3895, -66.1568),
    zoom: 14,
  );
  TGoogleMapController()
      : super(
          const GoogleMapState(
            markers: <Marker>{},
            polygons: <Polygon>{},
            polylines: <Polyline>{},
            cameraPosition: defaultCameraPosition,
          ),
        );

  final Completer<Null> readyCompleter = Completer<Null>();
  final cropButtonKey = GlobalKey<CropButtonState>();
  CameraPosition cameraPosition = TGoogleMapController.defaultCameraPosition;
  GoogleMapController? mapController;
  LatLngBounds? latLngBounds;

  @override
  Future<Null> get onReady => readyCompleter.future;

  @override
  void cleanMap() {
    emit(
      const GoogleMapState(
        markers: <Marker>{},
        polygons: <Polygon>{},
        polylines: <Polyline>{},
        cameraPosition: defaultCameraPosition,
      ),
    );
  }

  @override
  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) async {
    await moveCamera(center.toGoogleLatLng());
  }

  @override
  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  }) {
    final location1 = points.first.toGoogleLatLng();
    final location2 = points.last.toGoogleLatLng();
    LatLngBounds latLngBounds;
    if (location1.latitude > location2.latitude &&
        location1.longitude > location2.longitude) {
      latLngBounds = LatLngBounds(
        southwest: location2,
        northeast: location1,
      );
    } else if (location1.longitude > location2.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(location1.latitude, location2.longitude),
        northeast: LatLng(location2.latitude, location1.longitude),
      );
    } else if (location1.latitude > location2.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(location2.latitude, location1.longitude),
        northeast: LatLng(location1.latitude, location2.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: location1,
        northeast: location2,
      );
    }
    this.latLngBounds = latLngBounds;
    _moveCameraBounds(latLngBounds, padding: 60);
  }

  @override
  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  }) {
    if (latLngBounds != null) {
      _moveCameraBounds(latLngBounds!, padding: 60);
    }
  }

  @override
  Future<void> moveToYourLocation({
    required BuildContext context,
    required TrufiLatLng location,
    required double zoom,
    TickerProvider? tickerProvider,
  }) async {
    await moveCamera(location.toGoogleLatLng());
  }

  @override
  void selectedItinerary({
    required Plan plan,
    required TrufiLocation from,
    required TrufiLocation to,
    required TickerProvider tickerProvider,
    required Itinerary selectedItinerary,
    required Function(Itinerary p1) onTap,
  }) async {
    moveBounds(
      points: [
        from.latLng,
        to.latLng,
      ],
      tickerProvider: tickerProvider,
    );
  }

  void dispose() {
    mapController?.dispose();
    mapController = null;
  }

  Future<void> moveToCurrentLocation(LatLng? position) async {
    if (position == null) return;
    await moveCamera(position);
  }

  Future<void> moveCamera(LatLng target, {double zoom = 18}) async {
    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> onMarkerGenerated(
    List<Marker> _markers,
    List<MarkerId> _listIdsRemove, {
    Set<Polyline>? newPolylines,
  }) async {
    Set<Marker> auxMarkers = {...state.markers};
    if (_markers.isNotEmpty) {
      final markerMap = {
        for (final marker in _markers) marker.markerId.value: marker,
      };
      for (final markerR in markerMap.values) {
        auxMarkers
            .removeWhere((marker) => marker.markerId.value == markerR.markerId.value);
      }
      auxMarkers = {...auxMarkers, ...markerMap.values};
    }
    if (_listIdsRemove.isNotEmpty) {
      for (final markerId in _listIdsRemove) {
        auxMarkers
            .removeWhere((marker) => marker.markerId.value == markerId.value);
      }
    }
    emit(
      state.copyWith(
        markers: auxMarkers,
        polylines: newPolylines,
      ),
    );
  }

  Polyline addPolyline({
    required List<LatLng> points,
    required String polylineId,
    int strokeWidth = 6,
    int zIndex = 0,
    bool isDotted = false,
    Color? color,
  }) {
    return Polyline(
      color: color ?? Colors.black,
      polylineId: PolylineId(polylineId),
      points: points,
      patterns: isDotted ? [PatternItem.dot] : [],
      width: strokeWidth,
      zIndex: zIndex,
    );
  }

  Future<void> _moveCameraBounds(
    LatLngBounds bounds, {
    double padding = 60,
  }) async {
    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }
}
