import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_map_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_form_field.dart';

void main() {
  runApp(new TrufiApp());
}

class TrufiApp extends StatefulWidget {
  @override
  _TrufiAppState createState() => _TrufiAppState();
}

class _TrufiAppState extends State<TrufiApp>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<TrufiLocation>> _fromFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();
  final GlobalKey<FormFieldState<TrufiLocation>> _toFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();

  AnimationController controller;
  Animation<double> animation;
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;
  PlanItinerary itinerary;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 0.0, end: 42.0).animate(controller)
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
  Location _location = Location();
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
    ThemeData theme = ThemeData(primaryColor: const Color(0xffffd600));
    return MaterialApp(
      theme: theme,
      home: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              child: Container(),
              preferredSize: Size.fromHeight(animation.value),
            ),
            flexibleSpace: _buildFormFields(),
            leading: _isFromFieldVisible()
                ? IconButton(
                    icon: Icon(Platform.isIOS
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back),
                    onPressed: () => _reset(),
                  )
                : null,
          ),
          body: _buildPlan(theme),
        ),
      ),
    );
  }

  _buildFormFields() {
    List<Row> rows = List();
    if (_isFromFieldVisible()) {
      rows.add(
        _buildFormField(_fromFieldKey, "Origin", _setFromPlace),
      );
    }
    rows.add(
      _buildFormField(_toFieldKey, "Destination", _setToPlace),
    );
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: rows,
        ),
      ),
    );
  }

  _buildFormField(Key key, String hintText, Function(TrufiLocation) onSaved) {
    return Row(
      children: <Widget>[
        SizedBox(width: 40.0),
        Expanded(
          child: LocationFormField(
            key: key,
            hintText: hintText,
            onSaved: onSaved,
            yourLocation: _currentPosition(),
          ),
        ),
      ],
    );
  }

  LatLng _currentPosition() {
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
      itinerary = null;
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

  _setItinerary(PlanItinerary value) {
    setState(() {
      itinerary = value;
    });
  }

  _fetchPlan() async {
    if (toPlace != null) {
      if (fromPlace == null) {
        LatLng point = _currentPosition();
        fromPlace = TrufiLocation.fromLatLng("Current Position",
            point != null ? point : LatLng(-17.4603761, -66.1860606));
      }
      _setPlan(await api.fetchPlan(fromPlace, toPlace));
    }
  }

  bool _isFromFieldVisible() {
    return toPlace != null && controller.isCompleted;
  }

  Widget _buildPlan(ThemeData theme) {
    PlanError error = plan?.error;
    return Container(
      child: error != null
          ? _buildPlanFailure(error)
          : plan != null
              ? _buildPlanSuccessMap(theme, plan)
              : _buildPlanEmpty(),
    );
  }

  Widget _buildPlanFailure(PlanError error) {
    return Container(padding: EdgeInsets.all(8.0), child: Text(error.message));
  }

  Widget _buildPlanSuccess(Plan plan) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                ItineraryItem(plan.itineraries[index]),
            itemCount: plan.itineraries.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSuccessMap(ThemeData theme, Plan plan) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MapControllerPage(
            plan: plan,
            yourLocation: _currentPosition(),
            onSelected: (itinerary) => _setItinerary(itinerary),
          ),
        ),
        _buildItinerary(theme),
      ],
    );
  }

  _buildItinerary(ThemeData theme) {
    return itinerary != null
        ? Container(
            height: 200.0,
            child: SafeArea(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemBuilder: (BuildContext context, int index) {
                  PlanItineraryLeg leg = itinerary.legs[index];
                  return Row(
                    children: <Widget>[
                      Icon(leg.mode == 'WALK'
                          ? Icons.directions_walk
                          : Icons.directions_bus),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.body1,
                            text: leg.toInstruction(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: itinerary.legs.length,
              ),
            ),
          )
        : Container();
  }

  Widget _buildPlanEmpty() {
    return MapControllerPage(
      yourLocation: _currentPosition(),
    );
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
    return Row(
      children: <Widget>[Text(legs.points)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(itinerary);
  }
}
