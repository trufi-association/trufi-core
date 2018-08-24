import 'dart:async';

import 'package:composite_subscription/composite_subscription.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';
import 'package:trufi_app/trufi_models.dart';

class TrufiMap {
  final MapView mapView;
  final Marker fromMarker;
  final Marker toMarker;
  final Map<PlanItinerary, List<Polyline>> itineraries;
  final CompositeSubscription _subs = new CompositeSubscription();

  TrufiMap(this.mapView, this.fromMarker, this.toMarker, this.itineraries);

  factory TrufiMap.fromPlan(MapView mapView, Plan plan) {
    return new TrufiMap(
        mapView,
        _createMarker(plan.from.latitude, plan.from.longitude),
        _createMarker(plan.to.latitude, plan.to.longitude),
        _createItineraries(plan));
  }

  showMap() {
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location((fromMarker.latitude + toMarker.latitude) / 2.0,
                    (fromMarker.longitude + toMarker.longitude) / 2.0),
                12.0),
            hideToolbar: false,
            title: "Choose start position"),
        toolbarActions: [new ToolbarAction("Close", 1)]);

    // React on map ready
    StreamSubscription sub = mapView.onMapReady.listen((_) {
      itineraries.forEach((_, p) => p.forEach((p) => mapView.addPolyline(p)));
      mapView.setMarkers(<Marker>[fromMarker, toMarker]);
    });
    _subs.add(sub);

    // React on polyline touch
    sub = mapView.onTouchPolyline.listen((polyline) {
      _selectItineraryEntryForPolyline(polyline);
    });
    _subs.add(sub);

    // React on toolbar buttons
    sub = mapView.onToolbarAction.listen((id) {
      _hideMap();
    });
    _subs.add(sub);
  }

  _hideMap() async {
    mapView.dismiss();
    _subs.cancel();
  }

  _selectItineraryEntryForPolyline(Polyline polyline) {
    _unselectAllItineraries();
    _updateItineraryEntry(_itineraryEntryForPolyline(polyline), Colors.green);
  }

  _unselectAllItineraries() {
    itineraries.entries
        .forEach((entry) => _updateItineraryEntry(entry, Colors.grey));
  }

  _updateItineraryEntry(
      MapEntry<PlanItinerary, List<Polyline>> entry, Color color) {
    if (entry == null || color == null) return;
    List<Polyline> newPolylines = new List();
    Polyline newPolyline;
    entry.value.forEach((p) {
      newPolyline = new Polyline(p.id, p.points, color: color, width: p.width);
      newPolylines.add(newPolyline);
      mapView.removePolyline(p);
      mapView.addPolyline(newPolyline);
    });
    itineraries.addAll({entry.key: newPolylines});
  }

  MapEntry<PlanItinerary, List<Polyline>> _itineraryEntryForPolyline(
      Polyline polyline) {
    return itineraries.entries.firstWhere(
        (pair) =>
            pair.value
                .firstWhere((p) => p.id == polyline.id, orElse: () => null) !=
            null,
        orElse: () => null);
  }
}

Marker _createMarker(double latitude, double longitude) {
  return new Marker(
    "1",
    "Position",
    latitude,
    longitude,
    color: Colors.blue,
    draggable: true,
    markerIcon: new MarkerIcon(
      "assets/images/marker.png",
      width: 64.0,
      height: 64.0,
    ),
  );
}

Map<PlanItinerary, List<Polyline>> _createItineraries(Plan plan) {
  Map<PlanItinerary, List<Polyline>> itineraries = Map();
  int polylineId = 0;
  plan.itineraries.forEach((itinerary) {
    List<Polyline> polylines = List();
    itinerary.legs.forEach((leg) {
      List<Location> points = _decodePolyline(leg.points);
      polylines.add(new Polyline(polylineId.toString(), points,
          color: Colors.grey, width: 4.0));
      polylineId++;
    });
    itineraries.addAll({itinerary: polylines});
  });
  return itineraries;
}

List<Location> _decodePolyline(String encoded) {
  List<Location> points = new List<Location>();
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    Location p = new Location(lat / 1E5, lng / 1E5);
    points.add(p);
  }
  return points;
}
