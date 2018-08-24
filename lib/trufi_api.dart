import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_app/trufi_models.dart';

const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
const String SearchPath = '/otp/routers/default/geocode';
const String PlanPath = 'otp/routers/default/plan';

Future<List<TrufiLocation>> fetchLocations(String query) async {
  Uri request = Uri.https(Endpoint, SearchPath, {
    "query": query,
    "autocomplete": "false",
    "corners": "true",
    "stops": "false"
  });
  final response = await http.get(request);
  if (response.statusCode == 200) {
    return compute(_parseLocations, response.body);
  } else {
    throw Exception('Failed to load locations');
  }
}

List<TrufiLocation> _parseLocations(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed
      .map<TrufiLocation>((json) => new TrufiLocation.fromSearchJson(json))
      .toList();
}

Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) async {
  Uri request = Uri.https(Endpoint, PlanPath, {
    "fromPlace": from.toString(),
    "toPlace": to.toString(),
    "date": "01-01-2018",
    "mode": "TRANSIT,WALK"
  });
  final response = await http.get(request);
  if (response.statusCode == 200) {
    return compute(_parsePlan, response.body);
  } else {
    throw Exception('Failed to load plan');
  }
}

Plan _parsePlan(String responseBody) {
  final parsed = json.decode(responseBody);
  return Plan.fromJson(parsed);
}
