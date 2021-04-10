import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trufi_core/trufi_models.dart';

void main() {
  Plan _plan;
  PlanLocation _from;
  PlanLocation _to;
  List<PlanItinerary> _itineraries;

  String _fromName = "from_name";
  double _fromLatitude = 18.0;
  double _fromLongitude = 129.0;

  String _toName = "to_name";
  double _toLatitude = 18.45696;
  double _toLongitude = 129.826;
  PlanError _error;
  PlanItineraryLeg _leg;

  setUp(() {
    _from = new PlanLocation(
        name: _fromName, latitude: _fromLatitude, longitude: _fromLongitude);
    _to = new PlanLocation(
        name: _toName, latitude: _toLatitude, longitude: _toLongitude);

    _leg = new PlanItineraryLeg(
        points: "points",
        mode: "WALK",
        route: "route",
        routeLongName: "long_name_route",
        duration: 300.0,
        distance: 2.0);
    List<PlanItineraryLeg> legs = new List();
    legs.add(_leg);
    PlanItinerary itinerary = new PlanItinerary(legs: legs);
    _itineraries = new List();
    _itineraries.add(itinerary);
  });

  test('Create a plan', () {
    _plan = new Plan(from: _from, to: _to, itineraries: _itineraries);

    expect(_plan.from, _from);
    expect(_plan.to, _to);
    expect(_plan.itineraries, _itineraries);
  });

  test('Create a plan from json', () async {
    final file = new File('test/assets/response_plan.json');
    final jsonPlan = json.decode(await file.readAsString());
    _plan = Plan.fromJson(jsonPlan);

    expect(_plan.from.name, "Origin");
    expect(_plan.from.latitude, -17.3974935907119);
    expect(_plan.from.longitude, -66.28395080566406);
    expect(_plan.to.name, "Destination");
    expect(_plan.to.latitude, -17.36669500942906);
    expect(_plan.to.longitude, -66.18576049804688);
    expect(_plan.itineraries.first.legs.first.mode, "WALK");
    expect(_plan.itineraries.first.legs.last.duration, 191.0);
  });

  test('Plan from error ', () {
    PlanError planError = new PlanError(1, "error 2");
    Plan plan = new Plan(error: planError);
    // error id is -1 when generated with fromError.
    var plan2 = Plan.fromError("error 2");
    // id are different, so check messages
    expect(plan2.error.message, plan.error.message);
  });

  test('Plan toJson ', () {
    _plan = new Plan(from: _from, to: _to, itineraries: _itineraries);
    // the create of a new PlanLocation uses "latitude" and "longitude" words
    // but the toJson method, uses "lat" and "lon". It's not possible to compare
    // the objects using:
    // expect(jsonPlan.values.first.entries.containsValue(_from), true).
    var jsonPlan = _plan.toJson();
    expect(jsonPlan.length, 1);
    expect(jsonPlan.containsKey("plan"), true);
    expect(jsonPlan.values.first.containsKey("from"), true);
    expect(jsonPlan.values.first.containsKey("to"), true);
    expect(jsonPlan.values.first.containsKey('itineraries'), true);
  });

  test('Create Plan error fromJson', () {
    _error = new PlanError(1, "error 2");
    Plan plan = new Plan(error: _error);
    // error id is -1 when generated with fromError.
    var plan2 = Plan.fromError("error 2");
    // id are different, so check messages
    expect(plan2.error.message, plan.error.message);
  });

  test('Create Plan error with fromError', () async {
    final file = new File('test/assets/response_plan_error.json');
    final jsonPlan = json.decode(await file.readAsString());
    _plan = Plan.fromJson(jsonPlan);

    expect(_plan.error.message,
        "Trip is not possible.  Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).");
  });

  test('IconData return correct icon', () async {
    PlanItineraryLeg _legBus = new PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        route: "route",
        routeLongName: "take_bus",
        duration: 300.0,
        distance: 2.0);

    PlanItineraryLeg _legMinibus = new PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        route: "route",
        routeLongName: "take_minibus",
        duration: 300.0,
        distance: 2.0);

    PlanItineraryLeg _legTrufi = new PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        route: "route",
        routeLongName: "take_trufi",
        duration: 300.0,
        distance: 2.0);

    PlanItineraryLeg _legMicro = new PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        route: "route",
        routeLongName: "take_micro",
        duration: 300.0,
        distance: 2.0);

    expect(_leg.iconData(), Icons.directions_walk);
    expect(_legBus.iconData(), Icons.directions_bus);
    expect(_legMicro.iconData(), Icons.directions_bus);
    expect(_legMinibus.iconData(), Icons.airport_shuttle);
    expect(_legTrufi.iconData(), Icons.local_taxi);
  });
}
