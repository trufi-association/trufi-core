import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

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
  MapView.setApiKey(API_KEY);
  runApp(new TrufiApp());
}

class TrufiApp extends StatefulWidget {
  @override
  _TrufiAppState createState() => new _TrufiAppState();
}

class _PlanData {
  models.Location fromPlace = null;
  models.Location toPlace = null;
}

class _TrufiAppState extends State<TrufiApp> {
  _PlanData _planData = new _PlanData();
  MapView mapView = new MapView();

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
                          mapView: mapView),
                      new LocationField(
                          helperText: 'Choose your end location.',
                          labelText: 'End',
                          onSaved: (value) => _planData.toPlace = value,
                          mapView: mapView),
                      new Expanded(child: new Container()),
                      new Row(children: <Widget>[
                        new Expanded(
                            child: new RaisedButton(
                                color: Colors.blue,
                                onPressed: () => _submit(),
                                child: const Text("Go")))
                      ]),
                    ],
                  )))),
    );
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print(await fetchPlan(_planData.fromPlace, _planData.toPlace));
    }
  }
}
