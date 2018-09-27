import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
const String SearchPath = '/otp/routers/default/geocode';
const String PlanPath = 'otp/routers/default/plan';

class FetchRequestException implements Exception {
  FetchRequestException(this._innerException);

  final Exception _innerException;

  String toString() {
    return "Fetch request exception caused by: ${_innerException.toString()}";
  }
}

class FetchResponseException implements Exception {
  FetchResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "FetchResponseException: $_message";
  }
}

Future<List<TrufiLocation>> fetchLocations(
  BuildContext context,
  String query,
) async {
  Uri request = Uri.https(Endpoint, SearchPath, {
    "query": query,
    "autocomplete": "false",
    "corners": "true",
    "stops": "false"
  });
  final response = await fetchRequest(request);
  if (response.statusCode == 200) {
    List<TrufiLocation> locations = await compute(
      _parseLocations,
      utf8.decode(response.bodyBytes),
    );
    final FavoriteLocationsBloc favoriteLocationsBloc =
        BlocProvider.of<FavoriteLocationsBloc>(context);
    locations.sort((a, b){
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  } else {
    throw FetchResponseException('Failed to load locations');
  }
}

List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
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
  return Plan.fromJson(json.decode(responseBody));
}

Future<http.Response> fetchRequest(Uri request) async {
  try {
    return await http.get(request);
  } catch (e) {
    throw FetchRequestException(e);
  }
}
