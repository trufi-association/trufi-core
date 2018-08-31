import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_app/trufi_models.dart';

const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
const String SearchPath = '/otp/routers/default/geocode';
const String PlanPath = 'otp/routers/default/plan';

class FetchRequestException implements Exception {
  final Exception _innerException;

  FetchRequestException(this._innerException);

  String toString() {
    return "Fetch request exception caused by: ${_innerException.toString()}";
  }
}

class FetchResponseException implements Exception {
  final String _message;

  FetchResponseException(this._message);

  @override
  String toString() {
    return "FetchResponseException: $_message";
  }
}

Future<List<TrufiLocation>> fetchLocations(String query) async {
  Uri request = Uri.https(Endpoint, SearchPath, {
    "query": query,
    "autocomplete": "false",
    "corners": "true",
    "stops": "false"
  });
  final response = await fetchRequest(request);
  if (response.statusCode == 200) {
    return compute(_parseLocations, utf8.decode(response.bodyBytes));
  } else {
    throw FetchResponseException('Failed to load locations');
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
  final response = await fetchRequest(request);
  if (response.statusCode == 200) {
    return compute(_parsePlan, utf8.decode(response.bodyBytes));
  } else {
    throw FetchResponseException('Failed to load plan');
  }
}

Plan _parsePlan(String responseBody) {
  final parsed = json.decode(responseBody);
  return Plan.fromJson(parsed);
}

Future<http.Response> fetchRequest(Uri request) async {
  try {
    return await http.get(request);
  } catch (e) {
    throw FetchRequestException(e);
  }
}
