import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import '../../blocs/favorite_locations_bloc.dart';
import '../../blocs/preferences_bloc.dart';
import '../../blocs/request_manager_bloc.dart';
import '../../trufi_configuration.dart';
import '../../trufi_models.dart';

class OnlineRequestManager implements RequestManager {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';

  @override
  Future<List<dynamic>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
    LocationSearchBloc locationSearchBloc,
    PreferencesBloc preferencesBloc,
    String query, {
    int limit = 30,
  }) async {
    final Uri request = Uri.parse(
      TrufiConfiguration().url.otpEndpoint + searchPath,
    ).replace(queryParameters: {
      "query": query,
      "autocomplete": "false",
      "corners": "true",
      "stops": "false",
      "correlation": preferencesBloc.correlationId,
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
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _fetchCancelablePlan(context, from, to, "TRANSIT,WALK");
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _fetchCancelablePlan(context, from, to, "CAR,WALK");
  }

  @override
  CancelableOperation<Ad> fetchAd(
    BuildContext context,
    TrufiLocation to,
  ) {
    return _fetchCancelableAd(context, to);
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
            TrufiLocalization.of(context),
          ),
        );
      }
      return plan;
    }());
  }

  CancelableOperation<Ad> _fetchCancelableAd(
    BuildContext context,
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      final Ad ad = await _fetchAd(context, to);
      return ad;
    }());
  }

  Future<Plan> _fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
    String mode,
  ) async {
    final preferences = PreferencesBloc.of(context);
    final Uri request = Uri.parse(
      TrufiConfiguration().url.otpEndpoint + planPath,
    ).replace(queryParameters: {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": _todayMonthDayYear(),
      "numItineraries": "5",
      "mode": mode,
      "correlation": preferences.correlationId,
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<Ad> _fetchAd(
    BuildContext context,
    TrufiLocation to,
  ) async {
    final preferences = PreferencesBloc.of(context);

    if (TrufiConfiguration().url.adsEndpoint.isEmpty) {
      return null;
    }

    final Uri request = Uri.parse(
      TrufiConfiguration().url.adsEndpoint,
    ).replace(queryParameters: {
      "toPlace": to.toString(),
      "correlation": preferences.correlationId,
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
