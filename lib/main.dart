import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_map_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_form_field.dart';

/// This API Key will be used for both the interactive maps as well as the static maps.
/// Make sure that you have enabled the following APIs in the Google API Console (https://console.developers.google.com/apis)
/// - Static Maps API
/// - Android Maps API
/// - iOS Maps API
const API_KEY = "AIzaSyCwy00GIadUfbt3zFv0QyGCVynssQRGnhw";

void main() {
  runApp(new TrufiApp());
}

class TrufiApp extends StatefulWidget {
  @override
  _TrufiAppState createState() => new _TrufiAppState();
}

class _TrufiAppState extends State<TrufiApp>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<TrufiLocation>> _fromFieldKey =
      new GlobalKey<FormFieldState<TrufiLocation>>();
  final GlobalKey<FormFieldState<TrufiLocation>> _toFieldKey =
      new GlobalKey<FormFieldState<TrufiLocation>>();

  AnimationController controller;
  Animation<double> animation;
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 10.0, end: 72.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    initPlatformState();
    _locationSubscription =
        _location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  StreamSubscription<Map<String, double>> _locationSubscription;
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;
  Location _location = new Location();
  bool _permission = false;
  String error;

  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();
      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }
      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    setState(() {
      _startLocation = location;
    });
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primaryColor: const Color(0xffffd600)),
      home: new Form(
        key: _formKey,
        child: new Scaffold(
          appBar: new AppBar(
            bottom: new PreferredSize(
              child: new Container(),
              preferredSize: new Size.fromHeight(animation.value),
            ),
            flexibleSpace: new Container(
              padding: new EdgeInsets.all(8.0),
              child: _buildFormFields(),
            ),
          ),
          body: new Container(
            child: _buildPlan(),
          ),
        ),
      ),
    );
  }

  _buildFormFields() {
    List<Row> rows = List();
    if (_isFromFieldVisible()) {
      rows.add(
        new Row(
          children: <Widget>[
            new SizedBox(
                width: 40.0,
                child: new IconButton(
                    icon: Icon(Icons.arrow_back), onPressed: () => _reset())),
            new Expanded(
              child: new LocationFormField(
                key: _fromFieldKey,
                labelText: 'Origin',
                onSaved: (value) => _setFromPlace(value),
                position: _currentPosition(),
              ),
            ),
          ],
        ),
      );
    }
    rows.add(
      new Row(
        children: <Widget>[
          new SizedBox(width: 40.0),
          new Expanded(
            child: new LocationFormField(
              key: _toFieldKey,
              labelText: 'Destination',
              onSaved: (value) => _setToPlace(value),
              position: _currentPosition(),
            ),
          ),
        ],
      ),
    );
    return new Column(mainAxisAlignment: MainAxisAlignment.end, children: rows);
  }

  _currentPosition() {
    if (_currentLocation != null) {
      return LatLng(
          _currentLocation['latitude'], _currentLocation['longitude']);
    }
    return null;
  }

  _reset() {
    _formKey.currentState.reset();
    setState(() {
      fromPlace = null;
      toPlace = null;
      plan = null;
      controller.reverse();
    });
  }

  _setFromPlace(TrufiLocation value) {
    setState(() {
      fromPlace = value;
      _fetchPlan();
    });
  }

  _setToPlace(TrufiLocation value) {
    setState(() {
      toPlace = value;
      if (toPlace != null) {
        controller.forward();
      }
      _fetchPlan();
    });
  }

  _setPlan(Plan value) {
    setState(() {
      plan = value;
    });
  }

  _fetchPlan() async {
    if (toPlace != null) {
      if (fromPlace == null) {
        fromPlace = new TrufiLocation(
          description: "Current Position",
          latitude: -17.4603761,
          longitude: -66.1860606,
        );
      }
      _setPlan(await api.fetchPlan(fromPlace, toPlace));
    }
  }

  bool _isFromFieldVisible() {
    return toPlace != null && controller.isCompleted;
  }

  _showMap() async {}

  Widget _buildPlan() {
    PlanError error = plan?.error;
    return new Container(
      child: error != null
          ? _buildPlanFailure(error)
          : plan != null ? _buildPlanSuccessMap(plan) : _buildPlanEmpty(),
    );
  }

  Widget _buildPlanFailure(PlanError error) {
    return new Container(child: new Text(error.message));
  }

  Widget _buildPlanSuccess(Plan plan) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Row(children: <Widget>[
          new Expanded(
              child: new RaisedButton(
                  color: const Color(0xffffd600),
                  onPressed: () => _showMap(),
                  child: const Text("Show on map")))
        ]),
        new Expanded(
          child: new ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                ItineraryItem(plan.itineraries[index]),
            itemCount: plan.itineraries.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSuccessMap(Plan plan) {
    return new MapControllerPage(plan: plan);
  }

  Widget _buildPlanEmpty() {
    return new MapControllerPage();
  }
}

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class ItineraryItem extends StatelessWidget {
  const ItineraryItem(this.itinerary);

  final PlanItinerary itinerary;

  Widget _buildTiles(PlanItinerary itinerary) {
    if (itinerary.legs.isEmpty) return ListTile(title: Text("empty"));
    return ExpansionTile(
      key: PageStorageKey<PlanItinerary>(itinerary),
      title: Text(itinerary.duration.toString()),
      children: itinerary.legs.map(_buildLegsTiles).toList(),
    );
  }

  Widget _buildLegsTiles(PlanItineraryLeg legs) {
    if (legs.points.isEmpty) return ListTile(title: Text("empty"));
    return new Row(
      children: <Widget>[new Text(legs.points)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(itinerary);
  }
}
