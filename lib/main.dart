import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_map.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_form_field.dart';

import 'package:trufi_app/map_controller_page.dart';

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

class _TrufiAppState extends State<TrufiApp>
    with SingleTickerProviderStateMixin {
  final MapView _mapView = new MapView();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  AnimationController controller;
  Animation<double> animation;
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 110.0, end: 190.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Trufi'),
          backgroundColor: const Color(0xffffd600),
          actions: toPlace != null
              ? <Widget>[
                  new IconButton(
                      icon: Icon(Icons.close), onPressed: () => _reset())
                ]
              : <Widget>[],
          bottom: new PreferredSize(
              child: new Container(
                padding: new EdgeInsets.all(8.0),
                child: new Form(
                  key: _formKey,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _isFromFieldVisible()
                          ? new LocationFormField(
                              helperText: 'Choose your origin location.',
                              labelText: 'Origin',
                              onSaved: (value) => _setFromPlace(value),
                              mapView: _mapView)
                          : new Container(),
                      new LocationFormField(
                          helperText: 'Choose your destination.',
                          labelText: 'Destination',
                          onSaved: (value) => _setToPlace(value),
                          mapView: _mapView),
                    ],
                  ),
                ),
              ),
              preferredSize: new Size.fromHeight(animation.value)),
        ),
        body: new Container(
          child: _buildPlan(),
        ),
      ),
    );
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
            longitude: -66.1860606);
      }
      _setPlan(await api.fetchPlan(fromPlace, toPlace));
    }
  }

  bool _isFromFieldVisible() {
    return toPlace != null && controller.isCompleted;
  }

  _showMap() async {
    new TrufiMap.fromPlan(_mapView, await api.fetchPlan(fromPlace, toPlace))
        .showMap();
  }

  Widget _buildPlan() {
    PlanError error = plan?.error;
    return new Container(
      child: error != null
          ? _buildPlanFailure(error)
          : plan != null ? _buildPlanSuccess(plan) : _buildPlanEmpty(),
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
