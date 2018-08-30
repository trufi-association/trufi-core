import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_map_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_form_field.dart';
import 'package:trufi_app/location/location_provider.dart';

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

  LocationProvider locationProvider;
  AnimationController controller;
  Animation<double> animation;
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;
  PlanItinerary itinerary;

  initState() {
    super.initState();
    locationProvider = LocationProvider()..init();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 0.0, end: 42.0).animate(controller)
      ..addListener(() {
        setState(() {});
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
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Form(
        key: _formKey,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(theme),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      bottom: PreferredSize(
        child: Container(),
        preferredSize: Size.fromHeight(animation.value),
      ),
      flexibleSpace: _buildFormFields(),
      leading: _buildResetButton(),
    );
  }

  Widget _buildFormFields() {
    List<Row> rows = List();
    bool swapLocationsEnabled = false;
    if (_isFromFieldVisible()) {
      rows.add(
        _buildFormField(_fromFieldKey, "Origin", _setFromPlace,
            initialValue: fromPlace),
      );
      swapLocationsEnabled = true;
    }
    rows.add(
      _buildFormField(_toFieldKey, "Destination", _setToPlace,
          trailing: swapLocationsEnabled
              ? GestureDetector(
                  onTap: () => _swapPlaces(),
                  child: Icon(Icons.swap_vert),
                )
              : null),
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

  Widget _buildResetButton() {
    if (!_isFromFieldVisible()) {
      return null;
    }
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
      onPressed: () => _reset(),
    );
  }

  Widget _buildFormField(
      Key key, String hintText, Function(TrufiLocation) onSaved,
      {TrufiLocation initialValue, Widget leading, Widget trailing}) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40.0,
          child: leading,
        ),
        Expanded(
          child: LocationFormField(
            key: key,
            hintText: hintText,
            onSaved: onSaved,
            initialValue: initialValue,
            yourLocation: locationProvider.location,
          ),
        ),
        SizedBox(
          width: 40.0,
          child: trailing,
        ),
      ],
    );
  }

  bool _isFromFieldVisible() {
    return toPlace != null && controller.isCompleted;
  }

  Widget _buildBody(ThemeData theme) {
    PlanError error = plan?.error;
    return Container(
      child: error != null
          ? _buildBodyError(error)
          : plan != null ? _buildBodyPlan(theme, plan) : _buildBodyEmpty(),
    );
  }

  Widget _buildBodyError(PlanError error) {
    return Container(padding: EdgeInsets.all(8.0), child: Text(error.message));
  }

  Widget _buildBodyPlan(ThemeData theme, Plan plan) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MapControllerPage(
            plan: plan,
            yourLocation: locationProvider.location,
            onSelected: (itinerary) => _setItinerary(itinerary),
          ),
        ),
        _buildItinerary(theme),
      ],
    );
  }

  Widget _buildItinerary(ThemeData theme) {
    return itinerary != null
        ? Container(
            height: 150.0,
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
        : null;
  }

  Widget _buildBodyEmpty() {
    return MapControllerPage(
      yourLocation: locationProvider.location,
    );
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
      if ((plan?.itineraries?.length ?? 0) > 0) {
        itinerary = plan.itineraries.first;
      }
    });
  }

  _setItinerary(PlanItinerary value) {
    setState(() {
      itinerary = value;
    });
  }

  _swapPlaces() {
    _toFieldKey.currentState.didChange(fromPlace);
    _fromFieldKey.currentState.didChange(toPlace);
    _toFieldKey.currentState.save();
    _fromFieldKey.currentState.save();
  }

  _fetchPlan() async {
    if (toPlace != null) {
      if (fromPlace == null) {
        _setFromPlace(
          TrufiLocation.fromLatLng(
            "Current Position",
            locationProvider.location,
          ),
        );
      } else {
        _setPlan(await api.fetchPlan(fromPlace, toPlace));
      }
    }
  }
}
