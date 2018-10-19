import 'dart:convert';
import 'dart:io';

import 'package:latlong/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_app/trufi_models.dart';

void main() {
  TrufiLocation trufiLocation;
  LatLng _latLng;
  String _description = "trufi_location";
  double _latitude = 18.0;
  double _longitude = 129.0;

  setUp(() {
    _latLng = new LatLng(_latitude, _longitude);
  });

  test('Create a trufi location', () {
    trufiLocation = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);

    expect(trufiLocation.description, _description);
    expect(trufiLocation.latitude, 18.0);
    expect(trufiLocation.longitude, 129.0);
  });

  test('Create a trufi location from LatLng', () {
    trufiLocation = TrufiLocation.fromLatLng(_description, _latLng);

    expect(trufiLocation.description, _description);
    expect(trufiLocation.latitude, 18.0);
    expect(trufiLocation.longitude, 129.0);
  });

  test('Load list <TrufiLocation> from locations json', () async {
    final file = new File('assets/data/places.json');
    List<TrufiLocation> _listJsonLocation = json
        .decode(await file.readAsString())
        .map<TrufiLocation>(
            (json) => new TrufiLocation.fromLocationsJson(json))
        .toList();

    expect(_listJsonLocation.first.description, "UMSS Entrada");
    expect(_listJsonLocation.first.latitude, -17.3939461);
    expect(_listJsonLocation.first.longitude, -66.1484697);

    expect(_listJsonLocation.last.description, "América Este");
    expect(_listJsonLocation.last.latitude, -17.3740982);
    expect(_listJsonLocation.last.longitude, -66.1378992);
  });

  test('Create TrufiLocation from planLocation', () {
    PlanLocation plan = new PlanLocation(
        name: _description, longitude: _longitude, latitude: _latitude);
    trufiLocation = new TrufiLocation.fromPlanLocation(plan);

    expect(trufiLocation.description, _description);
    expect(trufiLocation.latitude, _latitude);
    expect(trufiLocation.longitude, _longitude);
  });

  // almost the same test as fromImportantPlacesJson and fromSearchJson but calling fromJson method
  test('Load list<TrufiLocation> from json', () async {
    final file = new File('test/assets/response_location.json');
    List<TrufiLocation> _listJsonLocation = json
        .decode(await file.readAsString())
        .map<TrufiLocation>((json) => new TrufiLocation.fromJson(json))
        .toList();

    expect(
        _listJsonLocation.first.description, "corner road & Calle L. Balzan ");
    expect(_listJsonLocation.first.latitude, -17.401528900000002);
    expect(_listJsonLocation.first.longitude, -66.1937169);

    expect(_listJsonLocation.last.description,
        "corner Pasaje L & Calle Luis Calvo ");
    expect(_listJsonLocation.last.latitude, -17.3697205);
    expect(_listJsonLocation.last.longitude, -66.1522482);
  });

  test('trufi location toJson', () {
    trufiLocation = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);
    var jsonTrufiLocation = trufiLocation.toJson();

    expect(jsonTrufiLocation.length, 3);
    expect(jsonTrufiLocation.containsKey("description"), true);
    expect(jsonTrufiLocation.containsKey("latitude"), true);
    expect(jsonTrufiLocation.containsKey('longitude'), true);
    expect(jsonTrufiLocation.containsValue(_description), true);
    expect(jsonTrufiLocation.containsValue(_latitude), true);
    expect(jsonTrufiLocation.containsValue(_longitude), true);
  });

  test('trufi locations are equal', (){
    trufiLocation = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);

    var trufiLocation2 = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);

    expect(trufiLocation, trufiLocation2);
    expect(trufiLocation == trufiLocation2, true);
  });

  test('trufi locations are not equal', (){
    trufiLocation = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);

    var trufiLocation2 = new TrufiLocation(
        description: "another_description", latitude: 2.0, longitude: 2.0);

    expect(trufiLocation == trufiLocation2, false);
  });

  test('trufi location to string', (){
    trufiLocation = new TrufiLocation(
        description: _description, latitude: _latitude, longitude: _longitude);

    expect(trufiLocation.toString(), _latitude.toString()+","+_longitude.toString());
  });
}
