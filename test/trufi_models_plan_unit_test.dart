import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/route_entity.dart';

void main() {
  PlanEntity _plan;
  PlanLocation? _from;
  PlanLocation? _to;
  List<PlanItinerary>? _itineraries;

  const String _fromName = "from_name";
  const double _fromLatitude = 18.0;
  const double _fromLongitude = 129.0;

  const String _toName = "to_name";
  const double _toLatitude = 18.45696;
  const double _toLongitude = 129.826;
  PlanError _error;
  PlanItineraryLeg? _leg;

  setUp(() {
    _from = PlanLocation(
        name: _fromName, latitude: _fromLatitude, longitude: _fromLongitude);
    _to = PlanLocation(
        name: _toName, latitude: _toLatitude, longitude: _toLongitude);

    _leg = PlanItineraryLeg(
        points: "points",
        mode: "WALK",
        route: const RouteEntity(shortName: "route"),
        routeLongName: "long_name_route",
        duration: 300.0,
        distance: 2.0);
    final List<PlanItineraryLeg?> legs = [];
    legs.add(_leg);
    final PlanItinerary itinerary = PlanItinerary(legs: legs);
    _itineraries = [];
    _itineraries!.add(itinerary);
  });

  test('Create a plan', () {
    _plan = PlanEntity(from: _from, to: _to, itineraries: _itineraries);

    expect(_plan.from, _from);
    expect(_plan.to, _to);
    expect(_plan.itineraries, _itineraries);
  });

  test('Create a plan from json', () async {
    final file = File('test/assets/response_plan.json');
    final jsonPlan = json.decode(await file.readAsString());
    _plan = PlanEntity.fromJson(jsonPlan as Map<String, dynamic>);

    expect(_plan.from!.name, "Origin");
    expect(_plan.from!.latitude, -17.3974935907119);
    expect(_plan.from!.longitude, -66.28395080566406);
    expect(_plan.to!.name, "Destination");
    expect(_plan.to!.latitude, -17.36669500942906);
    expect(_plan.to!.longitude, -66.18576049804688);
    expect(_plan.itineraries!.first.legs.first!.mode, "WALK");
    expect(_plan.itineraries!.first.legs.last!.duration, 191.0);
  });

  test('Plan from error ', () {
    final PlanError planError = PlanError(1, "error 2");
    final PlanEntity plan = PlanEntity(error: planError);
    // error id is -1 when generated with fromError.
    final plan2 = PlanEntity.fromError("error 2");
    // id are different, so check messages
    expect(plan2.error!.message, plan.error!.message);
  });

  test('Plan toJson ', () {
    _plan = PlanEntity(from: _from, to: _to, itineraries: _itineraries);
    // the create of a new PlanLocation uses "latitude" and "longitude" words
    // but the toJson method, uses "lat" and "lon". It's not possible to compare
    // the objects using:
    // expect(jsonPlan.values.first.entries.containsValue(_from), true).
    final jsonPlan = _plan.toJson();
    expect(jsonPlan.length, 1);
    expect(jsonPlan.containsKey("plan"), true);
    expect(jsonPlan.values.first.containsKey("from"), true);
    expect(jsonPlan.values.first.containsKey("to"), true);
    expect(jsonPlan.values.first.containsKey('itineraries'), true);
  });

  test('Create Plan error fromJson', () {
    _error = PlanError(1, "error 2");
    final PlanEntity plan = PlanEntity(error: _error);
    // error id is -1 when generated with fromError.
    final plan2 = PlanEntity.fromError("error 2");
    // id are different, so check messages
    expect(plan2.error!.message, plan.error!.message);
  });

  test('Create Plan error with fromError', () async {
    final file = File('test/assets/response_plan_error.json');
    final jsonPlan = json.decode(await file.readAsString());
    _plan = PlanEntity.fromJson(jsonPlan as Map<String, dynamic>);

    expect(_plan.error!.message,
        "Trip is not possible.  Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).");
  });

  test('IconData return correct icon', () async {
    final PlanItineraryLeg _legBus = PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        // route: "route",
        routeLongName: "take_bus",
        duration: 300.0,
        distance: 2.0);

    final PlanItineraryLeg _legMinibus = PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        // route: "route",
        routeLongName: "take_minibus",
        duration: 300.0,
        distance: 2.0);

    final PlanItineraryLeg _legTrufi = PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        // route: "route",
        routeLongName: "take_trufi",
        duration: 300.0,
        distance: 2.0);

    final PlanItineraryLeg _legMicro = PlanItineraryLeg(
        points: "points",
        mode: "BUS",
        // route: "route",
        routeLongName: "take_micro",
        duration: 300.0,
        distance: 2.0);

    expect(_leg!.iconData, Icons.directions_walk);
    expect(_legBus.iconData, Icons.directions_bus);
    expect(_legMicro.iconData, Icons.directions_bus);
    expect(_legMinibus.iconData, Icons.airport_shuttle);
    expect(_legTrufi.iconData, Icons.local_taxi);
  });
}
