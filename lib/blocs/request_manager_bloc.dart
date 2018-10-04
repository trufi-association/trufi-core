import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_models.dart';

class RequestManagerBloc implements BlocBase, RequestManager {
  static RequestManagerBloc of(BuildContext context) {
    return BlocProvider.of<RequestManagerBloc>(context);
  }

  RequestManagerBloc(this.preferencesBloc) {
    _requestManager = _offlineRequestManager;
    _subscriptions.add(
      preferencesBloc.outChangeOnline.listen((online) {
        _requestManager =
            online ? _onlineRequestManager : _offlineRequestManager;
      }),
    );
  }

  final PreferencesBloc preferencesBloc;

  final _subscriptions = CompositeSubscription();
  final _offlineRequestManager = OfflineRequestManager();
  final _onlineRequestManager = OnlineRequestManager();

  RequestManager _requestManager;

  // Dispose

  @override
  void dispose() {
    _subscriptions.cancel();
  }

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
}

class FetchOfflineRequestException implements Exception {
  FetchOfflineRequestException(this._innerException);

  final Exception _innerException;

  String toString() {
    return "Fetch offline request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOfflineResponseException implements Exception {
  FetchOfflineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch offline response exception: $_message";
  }
}

class FetchOnlineRequestException implements Exception {
  FetchOnlineRequestException(this._innerException);

  final Exception _innerException;

  String toString() {
    return "Fetch online request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOnlineResponseException implements Exception {
  FetchOnlineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch online response exception: $_message";
  }
}

abstract class RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  );

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to);
}

class OfflineRequestManager implements RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    throw FetchOfflineRequestException(
      Exception("Fetch locations offline is not implemented yet."),
    );
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) async {
    throw FetchOfflineRequestException(
      Exception("Fetch plan offline is not implemented yet."),
    );
  }
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
      throw FetchOnlineResponseException('Failed to load locations');
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
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    try {
      return await http.get(request);
    } catch (e) {
      throw FetchOnlineRequestException(e);
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
