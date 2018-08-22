import 'dart:async';

import 'package:composite_subscription/composite_subscription.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart' as mv;
import 'package:map_view/polyline.dart' as mv_polyline;

import 'package:trufi_app/trufi_api.dart';
import 'package:trufi_app/trufi_models.dart' as models;
import 'package:trufi_app/ui/location_field.dart';

/// This API Key will be used for both the interactive maps as well as the static maps.
/// Make sure that you have enabled the following APIs in the Google API Console (https://console.developers.google.com/apis)
/// - Static Maps API
/// - Android Maps API
/// - iOS Maps API
const API_KEY = "AIzaSyCwy00GIadUfbt3zFv0QyGCVynssQRGnhw";

void main() {
  mv.MapView.setApiKey(API_KEY);
  runApp(new TrufiApp());
}

class TrufiApp extends StatefulWidget {
  @override
  _TrufiAppState createState() => new _TrufiAppState();
}

class PlanData {
  models.Location fromPlace;
  models.Location toPlace;
}

class _TrufiAppState extends State<TrufiApp> {
  final CompositeSubscription _subscription = new CompositeSubscription();
  final PlanData _planData = new PlanData();
  final mv.MapView _mapView = new mv.MapView();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Trufi'),
          ),
          body: new Container(
              padding: new EdgeInsets.all(16.0),
              child: new Form(
                  key: _formKey,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new LocationField(
                          helperText: 'Choose your start location.',
                          labelText: 'Start',
                          onSaved: (value) => _planData.fromPlace = value,
                          mapView: _mapView),
                      new LocationField(
                          helperText: 'Choose your end location.',
                          labelText: 'End',
                          onSaved: (value) => _planData.toPlace = value,
                          mapView: _mapView),
                      new Expanded(child: new Container()),
                      new Row(children: <Widget>[
                        new Expanded(
                            child: new RaisedButton(
                                color: Colors.blue,
                                onPressed: () => _submit(),
                                child: const Text("Go for it")))
                      ]),
                    ],
                  )))),
    );
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _showMap(await fetchPlan(_planData.fromPlace, _planData.toPlace));
    }
  }

  List<mv_polyline.Polyline> _polylines = List();
  mv.Marker _fromPosition;
  mv.Marker _toPosition;

  mv.Marker _createMarker(double latitude, double longitude) {
    return new mv.Marker(
      "1",
      "Position",
      latitude,
      longitude,
      color: Colors.blue,
      draggable: true,
      markerIcon: new mv.MarkerIcon(
        "images/marker.png",
        width: 64.0,
        height: 64.0,
      ),
    );
  }

  _showMap(models.Plan plan) {
    _polylines = List();
    _fromPosition = _createMarker(plan.from.latitude, plan.from.longitude);
    _toPosition = _createMarker(plan.to.latitude, plan.to.longitude);
    plan.itineraries.forEach((itinerary) {
      itinerary.legs.forEach((leg) {
        List<mv.Location> points = _decodePolyline(leg.points);
        _polylines.add(new mv_polyline.Polyline(leg.toString(), points));
      });
    });

    _mapView.show(
        new mv.MapOptions(
            mapViewType: mv.MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new mv.CameraPosition(
                new mv.Location((plan.from.latitude + plan.to.latitude) / 2.0,
                    (plan.from.longitude + plan.to.longitude) / 2.0),
                12.0),
            hideToolbar: false,
            title: "Choose start position"),
        toolbarActions: [new mv.ToolbarAction("Close", 1)]);
    StreamSubscription sub = _mapView.onMapReady.listen((_) {
      _mapView.setPolylines(_polylines);
      _mapView.setMarkers(<mv.Marker>[_fromPosition, _toPosition]);
    });
    _subscription.add(sub);

    // React on toolbar buttons
    sub = _mapView.onToolbarAction.listen((id) {
      _hideMap();
    });
    _subscription.add(sub);
  }

  _hideMap() async {
    _mapView.dismiss();
    _subscription.cancel();
  }

  List<mv.Location> _decodePolyline(String encoded) {
    List<mv.Location> poly = new List<mv.Location>();
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
      mv.Location p = new mv.Location(lat / 1E5, lng / 1E5);
      poly.add(p);
    }
    return poly;
  }
}
