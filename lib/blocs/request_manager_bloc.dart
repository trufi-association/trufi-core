import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class RequestManagerBloc implements BlocBase, RequestManager {
  static RequestManagerBloc of(BuildContext context) {
    return BlocProvider.of<RequestManagerBloc>(context);
  }

  final _onlineRequestManager = OnlineRequestManager();

  // Dispose

  @override
  void dispose() {}

  // Methods

  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) {
    return _requestManager.fetchLocations(context, query);
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) {
    return _requestManager.fetchPlan(from, to);
  }

  // Getter

  RequestManager get _requestManager => _onlineRequestManager;
}

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

abstract class RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  );

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to);
}

class OnlineRequestManager implements RequestManager {
  static const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
  static const String SearchPath = '/otp/routers/default/geocode';
  static const String PlanPath = 'otp/routers/default/plan';

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
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      List<TrufiLocation> locations = await compute(
        _parseLocations,
        utf8.decode(response.bodyBytes),
      );
      final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
      locations.sort((a, b) {
        return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
      });
      return locations;
    } else {
      throw FetchResponseException('Failed to load locations');
    }
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) async {
    Uri request = Uri.https(Endpoint, PlanPath, {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": "01-01-2018",
      "mode": "TRANSIT,WALK"
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
    } else {
      throw FetchResponseException('Failed to load plan');
    }
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    try {
      return await http.get(request);
    } catch (e) {
      throw FetchRequestException(e);
    }
  }
}

List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
      .map<TrufiLocation>((json) => new TrufiLocation.fromSearchJson(json))
      .toList();
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody));
}
