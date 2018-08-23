import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import 'package:trufi_app/trufi_api.dart';
import 'package:trufi_app/trufi_map.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/ui/location_form_field.dart';

/// This API Key will be used for both the interactive maps as well as the static maps.
/// Make sure that you have enabled the following APIs in the Google API Console (https://console.developers.google.com/apis)
/// - Static Maps API
/// - Android Maps API
/// - iOS Maps API
const API_KEY = "AIzaSyCwy00GIadUfbt3zFv0QyGCVynssQRGnhw";

void main() {
  MapView.setApiKey(API_KEY);
  runApp(new TrufiApp());
}

class TrufiApp extends StatefulWidget {
  @override
  _TrufiAppState createState() => new _TrufiAppState();
}

class PlanData {
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;

  reset() {
    fromPlace = null;
    toPlace = null;
    plan = null;
  }
}

class _TrufiAppState extends State<TrufiApp> {
  final PlanData _planData = new PlanData();
  final MapView _mapView = new MapView();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
              title: new Text('Trufi'),
              actions: _planData.toPlace != null
                  ? <Widget>[
                      new IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _formKey.currentState.reset();
                            setState(() {
                              _planData.reset();
                            });
                          })
                    ]
                  : <Widget>[]),
          body: new Container(
              padding: new EdgeInsets.all(16.0),
              child: new Form(
                  key: _formKey,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _planData.toPlace != null
                          ? new LocationFormField(
                              helperText: 'Choose your origin location.',
                              labelText: 'Origin',
                              onSaved: (value) {
                                print(value);
                                setState(() {
                                  _planData.fromPlace = value;
                                  _fetchPlan();
                                });
                              },
                              mapView: _mapView)
                          : new Container(),
                      new LocationFormField(
                          helperText: 'Choose your destination.',
                          labelText: 'Destination',
                          onSaved: (value) {
                            print(value);
                            setState(() {
                              _planData.toPlace = value;
                              _fetchPlan();
                            });
                          },
                          mapView: _mapView),
                      _planData.plan != null
                          ? new Row(children: <Widget>[
                              new Expanded(
                                  child: new RaisedButton(
                                      color: Colors.blue,
                                      onPressed: () => _submit(),
                                      child: const Text("Show on map")))
                            ])
                          : new Container(),
                    ],
                  )))),
    );
  }

  _fetchPlan() async {
    if (_planData.toPlace != null) {
      if (_planData.fromPlace == null) {
        _planData.fromPlace = new TrufiLocation(
            description: "Current Position",
            latitude: -17.4603761,
            longitude: -66.1860606);
      }
      Plan plan = await fetchPlan(_planData.fromPlace, _planData.toPlace);
      setState(() {
        _planData.plan = plan;
      });
    }
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      new TrufiMap.fromPlan(
              _mapView, await fetchPlan(_planData.fromPlace, _planData.toPlace))
          .showMap();
    }
  }
}
