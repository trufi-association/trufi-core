import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_app/trufi_models.dart' as models;

const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com:8080';
const String SearchPath = '/otp/routers/default/geocode';

Future<List<models.Location>> fetchLocations(String query) async {
  Uri request = Uri.http(Endpoint, SearchPath, {
    "query": query,
    "autocomplete": "true",
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

List<models.Location> _parseLocations(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<models.Location>((json) => new models.Location.fromJson(json))
      .toList();
}
