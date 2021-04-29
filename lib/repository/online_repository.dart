import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

class OnlineRepository implements RequestManager {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';
  final String otpEndpoint;
  final String adsEndpoint;

  OnlineRepository({@required this.otpEndpoint, this.adsEndpoint});

  @override
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
    int limit = 30,
  }) async {
    final Uri request = Uri.parse(
      otpEndpoint + searchPath,
    ).replace(queryParameters: {
      "query": query,
      "autocomplete": "false",
      "corners": "true",
      "stops": "false",
      "correlation": correlationId,
    });
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

  @override
  CancelableOperation<Plan> fetchTransitPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(from, to, "TRANSIT,WALK", correlationId);
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(from, to, "CAR,WALK", correlationId);
  }

  @override
  CancelableOperation<Ad> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelableAd(to, correlationId);
  }

  CancelableOperation<Plan> _fetchCancelablePlan(
    TrufiLocation from,
    TrufiLocation to,
    String mode,
    String correlationId,
  ) {
    return CancelableOperation.fromFuture(() async {
      final Plan plan = await _fetchPlan(from, to, mode, correlationId);
      return plan;
    }());
  }

  CancelableOperation<Ad> _fetchCancelableAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return CancelableOperation.fromFuture(() async {
      final Ad ad = await _fetchAd(to, correlationId);
      return ad;
    }());
  }

  Future<Plan> _fetchPlan(
    TrufiLocation from,
    TrufiLocation to,
    String mode,
    String correlationId,
  ) async {
    final Uri request = Uri.parse(
      otpEndpoint + planPath,
    ).replace(queryParameters: {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": _todayMonthDayYear(),
      "numItineraries": "5",
      "mode": mode,
      "correlation": correlationId,
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<Ad> _fetchAd(
    TrufiLocation to,
    String correlationId,
  ) async {
    final adEndpoint = adsEndpoint;
    if (adEndpoint == null || adEndpoint.isEmpty) {
      return null;
    }

    final Uri request = Uri.parse(
      adsEndpoint,
    ).replace(queryParameters: {
      "toPlace": to.toString(),
      "correlation": correlationId,
      "language": Intl.getCurrentLocale()
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parseAd, utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      // TODO: Remove Print and replace by proper error handling
      // ignore: avoid_print
      print("No ads found");
    }
    // TODO: remove print and replace by proper error handling
    // ignore: avoid_print
    print("Error fetching ads");

    return null;
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return await http.get(request, headers: {
        "User-Agent": "Trufi/${packageInfo.version}",
      });
    } on Exception catch (e) {
      throw FetchOnlineRequestException(e);
    }
  }

  String _todayMonthDayYear() {
    final today = DateTime.now();
    return "${today.month.toString().padLeft(2, '0')}-" +
        "${today.day.toString().padLeft(2, '0')}-" +
        today.year.toString();
  }

// TODO link again with localization error
  // ignore: unused_element
  String _localizedErrorForPlanError(
    PlanError error,
    TrufiLocalization localization,
  ) {
    if (error.id == 500 || error.id == 503) {
      return localization.errorServerUnavailable;
    } else if (error.id == 400) {
      return localization.errorOutOfBoundary;
    } else if (error.id == 404) {
      return localization.errorPathNotFound;
    } else if (error.id == 406) {
      return localization.errorNoTransitTimes;
    } else if (error.id == 408) {
      return localization.errorServerTimeout;
    } else if (error.id == 409) {
      return localization.errorTrivialDistance;
    } else if (error.id == 413) {
      return localization.errorServerCanNotHandleRequest;
    } else if (error.id == 440) {
      return localization.errorUnknownOrigin;
    } else if (error.id == 450) {
      return localization.errorUnknownDestination;
    } else if (error.id == 460) {
      return localization.errorUnknownOriginDestination;
    } else if (error.id == 470) {
      return localization.errorNoBarrierFree;
    } else if (error.id == 340) {
      return localization.errorAmbiguousOrigin;
    } else if (error.id == 350) {
      return localization.errorAmbiguousDestination;
    } else if (error.id == 360) {
      return localization.errorAmbiguousOriginDestination;
    }
    return error.message;
  }
}

List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
      .map<TrufiLocation>(
          (Map<String, dynamic> json) => TrufiLocation.fromSearch(json))
      .toList() as List<TrufiLocation>;
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody) as Map<String, dynamic>);
}

Ad _parseAd(String responseBody) {
  return Ad.fromJson(json.decode(responseBody) as Map<String, dynamic>);
}
