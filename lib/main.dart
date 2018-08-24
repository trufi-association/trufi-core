import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_map.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_form_field.dart';

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
          padding: new EdgeInsets.all(16.0),
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

  bool _isPlanVisible() {
    return plan != null;
  }

  bool _isPlanErrorVisible() {
    return plan?.error != null ?? false;
  }

  _showMap() async {
    new TrufiMap.fromPlan(_mapView, await api.fetchPlan(fromPlace, toPlace))
        .showMap();
  }

  Widget _buildPlan() {
    PlanError error = plan?.error;
    return new Container(
      padding: new EdgeInsets.all(16.0),
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
      ],
    );
  }

  Widget _buildPlanEmpty() {
    return new Container();
  }
}

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

final List<Entry> data = <Entry>[
  Entry(
    'Chapter A',
    <Entry>[
      Entry(
        'Section A0',
        <Entry>[
          Entry('Item A0.1'),
          Entry('Item A0.2'),
          Entry('Item A0.3'),
        ],
      ),
      Entry('Section A1'),
      Entry('Section A2'),
    ],
  ),
  Entry(
    'Chapter B',
    <Entry>[
      Entry('Section B0'),
      Entry('Section B1'),
    ],
  ),
  Entry(
    'Chapter C',
    <Entry>[
      Entry('Section C0'),
      Entry('Section C1'),
      Entry(
        'Section C2',
        <Entry>[
          Entry('Item C2.0'),
          Entry('Item C2.1'),
          Entry('Item C2.2'),
          Entry('Item C2.3'),
        ],
      ),
    ],
  ),
];
