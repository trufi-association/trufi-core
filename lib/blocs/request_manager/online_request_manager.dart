import 'dart:async';
import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class OnlineRequestManager implements RequestManager {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';

  Future<List<dynamic>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  ) async {
    final urlOtpEndpoint = GlobalConfiguration().getString("urlOtpEndpoint");
    Uri request = Uri
      .parse(urlOtpEndpoint + searchPath)
      .replace(queryParameters: {
        "query": query,
        "autocomplete": "false",
        "corners": "true",
        "stops": "false",
      });
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      final locations = await compute(
        _parseLocations,
        utf8.decode(response.bodyBytes),
      );
      // Favorites to the top
      locations.sort((a, b) {
        return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
      });
      // Cutoff by limit
      if (locations.length > limit) {
        locations.removeRange(limit, locations.length);
      }
      return locations;
    } else {
      throw FetchOnlineResponseException('Failed to load locations');
    }
  }

  CancelableOperation<Plan> fetchTransitPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _fetchCancelablePlan(context, from, to, "TRANSIT,WALK");
  }

  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _fetchCancelablePlan(context, from, to, "CAR,WALK");
  }

  CancelableOperation<Plan> _fetchCancelablePlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
    String mode,
  ) {
    return CancelableOperation.fromFuture(() async {
      Plan plan = await _fetchPlan(context, from, to, mode);
      if (plan.hasError) {
        plan = Plan.fromError(
          _localizedErrorForPlanError(
            plan.error,
            TrufiLocalizations.of(context),
          ),
        );
      }
      return plan;
    }());
  }

  Future<Plan> _fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
    String mode,
  ) async {
    final urlOtpEndpoint = GlobalConfiguration().getString("urlOtpEndpoint");
    Uri request = Uri
      .parse(urlOtpEndpoint + planPath)
      .replace(queryParameters: {
        "fromPlace": from.toString(),
        "toPlace": to.toString(),
        "date": "04.03.2019",
        "numItineraries":"5",
        "mode": mode
      });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return await compute(_parsePlan, utf8.decode(response.bodyBytes));
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

  String _localizedErrorForPlanError(
    PlanError error,
    TrufiLocalizations localizations,
  ) {
    if (error.id == 500 || error.id == 503) {
      return localizations.errorServerUnavailable();
    } else if (error.id == 400) {
      return localizations.errorOutOfBoundary();
    } else if (error.id == 404) {
      return localizations.errorPathNotFound();
    } else if (error.id == 406) {
      return localizations.errorNoTransitTimes();
    } else if (error.id == 408) {
      return localizations.errorServerTimeout();
    } else if (error.id == 409) {
      return localizations.errorTrivialDistance();
    } else if (error.id == 413) {
      return localizations.errorServerCanNotHandleRequest();
    } else if (error.id == 440) {
      return localizations.errorUnknownOrigin();
    } else if (error.id == 450) {
      return localizations.errorUnknownDestination();
    } else if (error.id == 460) {
      return localizations.errorUnknownOriginDestination();
    } else if (error.id == 470) {
      return localizations.errorNoBarrierFree();
    } else if (error.id == 340) {
      return localizations.errorAmbiguousOrigin();
    } else if (error.id == 350) {
      return localizations.errorAmbiguousDestination();
    } else if (error.id == 360) {
      return localizations.errorAmbiguousOriginDestination();
    }
    return error.message;
  }
}

List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
      .map<TrufiLocation>((json) => TrufiLocation.fromSearch(json))
      .toList();
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody));
}
