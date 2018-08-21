import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

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

class _TrufiAppState extends State<TrufiApp> {
  MapView mapView = new MapView();

  final GlobalKey<FormFieldState<String>> _startLocationFieldKey =
      new GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _endLocationFieldKey =
      new GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Trufi'),
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                padding: EdgeInsets.all(16.0),
                child: new LocationField(
                    fieldKey: _startLocationFieldKey,
                    helperText: 'Choose your start location.',
                    labelText: 'Start',
                    mapView: mapView),
              ),
              new Container(
                padding: EdgeInsets.all(16.0),
                child: new LocationField(
                    fieldKey: _endLocationFieldKey,
                    helperText: 'Choose your end location.',
                    labelText: 'End',
                    mapView: mapView),
              ),
            ],
          )),
    );
  }
}
