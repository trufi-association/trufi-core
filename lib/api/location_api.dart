import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

Future<List<Location>> fetchLocations(String query) async {
  final response = await http.get(
      'http://trufiapp.westeurope.cloudapp.azure.com:8080/otp/routers/default/geocode?autocomplete=true&corners=true&query=$query&stops=false');
  if (response.statusCode == 200) {
    return compute(parseLocations, response.body);
  } else {
    throw Exception('Failed to load post');
  }
}

List<Location> parseLocations(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Location>((json) => new Location.fromJson(json)).toList();
}

class Location {
  final String description;
  final double latitude;
  final double longitude;

  Location({this.description, this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      description: json['description'],
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }
}
