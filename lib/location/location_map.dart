import 'dart:async';

import 'package:composite_subscription/composite_subscription.dart';
import 'package:map_view/map_view.dart';
import 'package:trufi_app/trufi_map_utils.dart';

typedef void OnSubmit(double latitude, double longitude);
typedef void OnCancel();

class LocationMap {
  final MapView mapView;
  final Marker locationMarker;
  final OnSubmit onSubmit;
  final OnCancel onCancel;

  final CompositeSubscription _subs = new CompositeSubscription();

  LocationMap(this.mapView, this.locationMarker,
      {this.onSubmit, this.onCancel});

  factory LocationMap.create(MapView mapView,
      {OnSubmit onSubmit, OnCancel onCancel}) {
    return new LocationMap(mapView, createPositionMarker(-17.0, -66.0),
        onSubmit: onSubmit, onCancel: onCancel);
  }

  showMap() {
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location(locationMarker.latitude, locationMarker.longitude),
                15.0),
            hideToolbar: false,
            title: "Choose start position"),
        toolbarActions: [
          new ToolbarAction("❌", 1),
          new ToolbarAction("✔️", 2)
        ]);

    // React on map ready
    StreamSubscription sub = mapView.onMapReady.listen((_) {
      mapView.addMarker(locationMarker);
    });
    _subs.add(sub);

    // React on toolbar buttons
    sub = mapView.onToolbarAction.listen((id) {
      _hideMap(id);
    });
    _subs.add(sub);
  }

  _hideMap(int id) async {
    if (id == 1) {
      if (onCancel != null) {
        onCancel();
      }
    } else if (id == 2) {
      if (onSubmit != null) {
        onSubmit(locationMarker.latitude, locationMarker.longitude);
      }
    }
    mapView.dismiss();
    _subs.cancel();
  }
}
