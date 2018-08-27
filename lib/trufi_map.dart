import 'dart:async';

import 'package:composite_subscription/composite_subscription.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';

class TrufiMap {
  final MapView mapView;
  final Plan plan;
  final Marker fromMarker;
  final Marker toMarker;
  final CompositeSubscription _subs = new CompositeSubscription();

  Map<PlanItinerary, List<Polyline>> itineraries;
  PlanItinerary selectedItinerary;

  TrufiMap(this.mapView, this.plan, this.fromMarker, this.toMarker,
      this.itineraries, this.selectedItinerary);

  factory TrufiMap.fromPlan(MapView mapView, Plan plan) {
    PlanItinerary selectedItinerary = plan.itineraries.first;
    return new TrufiMap(
        mapView,
        plan,
        createOriginMarker(plan.from.latitude, plan.from.longitude),
        createDestinationMarker(plan.to.latitude, plan.to.longitude),
        createItineraries(plan, selectedItinerary),
        selectedItinerary);
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
                13.0),
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
    PlanItinerary selectedItinerary = _itineraryForPolyline(polyline);
    if (selectedItinerary != null) {
      itineraries.entries.forEach((entry) {
        entry.value.forEach((p) => mapView.removePolyline(p));
      });
      itineraries.clear();
      itineraries = createItineraries(plan, selectedItinerary);
      itineraries.forEach((_, p) => p.forEach((p) => mapView.addPolyline(p)));
    }
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    MapEntry<PlanItinerary, List<Polyline>> entry =
        _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
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

Map<PlanItinerary, List<Polyline>> createItineraries(
    Plan plan, PlanItinerary selectedItinerary) {
  Map<PlanItinerary, List<Polyline>> itineraries = Map();
  int polylineId = 0;
  plan.itineraries.forEach((itinerary) {
    List<Polyline> polylines = List();
    bool isSelected = itinerary == selectedItinerary;
    itinerary.legs.forEach((leg) {
      List<Location> points = decodePolyline(leg.points);
      Polyline polyline = new Polyline(polylineId.toString(), points,
          color: isSelected
              ? leg.mode == 'WALK' ? Colors.blue : Colors.green
              : Colors.grey,
          width: isSelected ? 6.0 : 3.0);
      polylines.add(polyline);
      polylineId++;
    });
    itineraries.addAll({itinerary: polylines});
  });
  return itineraries;
}
