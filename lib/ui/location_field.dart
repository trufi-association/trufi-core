import 'dart:async';

import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';
import 'package:map_view/polygon.dart';
import 'package:map_view/polyline.dart';

class LocationField extends StatefulWidget {
  const LocationField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.mapView,
    this.staticMapProvider
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final MapView mapView;
  final StaticMapProvider staticMapProvider;

  @override
  _LocationFieldState createState() => new _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {

  CameraPosition cameraPosition;
  var compositeSubscription = new CompositeSubscription();
  Uri staticMapUri;

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      key: widget.fieldKey,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: new InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: new GestureDetector(
          onTap: () {
            showMap();
          },
          child: new Icon(Icons.add_location),
        ),
      ),
    );
  }

  showMap() {
    widget.mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location(45.526607443935724, -122.66731660813093), 15.0),
            hideToolbar: false,
            title: "Recently Visited"),
        toolbarActions: [
          new ToolbarAction("❌", 1),
          new ToolbarAction("✔️", 2)
        ]);
    StreamSubscription sub = widget.mapView.onMapReady.listen((_) {
//      mapView.setMarkers(_markers);
//      mapView.setPolylines(_lines);
//      mapView.setPolygons(_polygons);
    });
    compositeSubscription.add(sub);
    sub = widget.mapView.onLocationUpdated.listen((location) {
      print("Location updated $location");
    });
    compositeSubscription.add(sub);
    sub = widget.mapView.onTouchAnnotation
        .listen((annotation) => print("annotation ${annotation.id} tapped"));
    compositeSubscription.add(sub);
    sub = widget.mapView.onTouchPolyline
        .listen((polyline) => print("polyline ${polyline.id} tapped"));
    compositeSubscription.add(sub);
    sub = widget.mapView.onTouchPolygon
        .listen((polygon) => print("polygon ${polygon.id} tapped"));
    compositeSubscription.add(sub);
    sub = widget.mapView.onMapTapped
        .listen((location) => print("Touched location $location"));
    compositeSubscription.add(sub);
    sub = widget.mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));
    compositeSubscription.add(sub);
    sub = widget.mapView.onAnnotationDragStart.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging started");
    });
    sub = widget.mapView.onAnnotationDragEnd.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging ended");
    });
    sub = widget.mapView.onAnnotationDrag.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker];
      print("Annotation ${marker.id} moved to ${location.latitude} , ${location
          .longitude}");
    });
    compositeSubscription.add(sub);
    sub = widget.mapView.onToolbarAction.listen((id) {
      print("Toolbar button id = $id");
      _handleDismiss(id != 1);
    });
    compositeSubscription.add(sub);
    sub = widget.mapView.onInfoWindowTapped.listen((marker) {
      print("Info Window Tapped for ${marker.title}");
    });
    compositeSubscription.add(sub);
  }

  _handleDismiss(bool submit) async {
    if (submit) {
      double zoomLevel = await widget.mapView.zoomLevel;
      Location centerLocation = await widget.mapView.centerLocation;
      List<Marker> visibleAnnotations = await widget.mapView.visibleAnnotations;
      List<Polyline> visibleLines = await widget.mapView.visiblePolyLines;
      List<Polygon> visiblePolygons = await widget.mapView.visiblePolygons;
      print("Zoom Level: $zoomLevel");
      print("Center: $centerLocation");
      print("Visible Annotation Count: ${visibleAnnotations.length}");
      print("Visible Polylines Count: ${visibleLines.length}");
      print("Visible Polygons Count: ${visiblePolygons.length}");
      var uri = await widget.staticMapProvider.getImageUriFromMap(widget.mapView,
          width: 900, height: 400);
      setState(() => staticMapUri = uri);
    }
    widget.mapView.dismiss();
    compositeSubscription.cancel();
  }
}

class CompositeSubscription {
  Set<StreamSubscription> _subscriptions = new Set();

  void cancel() {
    for (var n in this._subscriptions) {
      n.cancel();
    }
    this._subscriptions = new Set();
  }

  void add(StreamSubscription subscription) {
    this._subscriptions.add(subscription);
  }

  void addAll(Iterable<StreamSubscription> subs) {
    _subscriptions.addAll(subs);
  }

  bool remove(StreamSubscription subscription) {
    return this._subscriptions.remove(subscription);
  }

  bool contains(StreamSubscription subscription) {
    return this._subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return this._subscriptions.toList();
  }
}
