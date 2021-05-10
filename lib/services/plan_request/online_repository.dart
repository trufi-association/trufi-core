import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/trufi_models.dart';

import 'request_manager.dart';

class OnlineRepository implements RequestManager {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';
  final String otpEndpoint;
  final String adsEndpoint;

  OnlineRepository({@required this.otpEndpoint, this.adsEndpoint});

  @override
  Future<PlanEntity> fetchAdvancedPlan({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required String correlationId,
    SettingPanelState advancedOptions,
  }) {
    if (advancedOptions == null) {
      return _fetchPlan(from, to, "TRANSIT,WALK", correlationId);
    } else {
      // TODO implement fetchAdvancedPlan
      return _fetchPlan(from, to, "TRANSIT,WALK", correlationId);
    }
  }

  @override
  Future<PlanEntity> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchPlan(from, to, "CAR,WALK", correlationId);
  }

  @override
  Future<AdEntity> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchAd(to, correlationId);
  }

  Future<PlanEntity> _fetchPlan(
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

  Future<AdEntity> _fetchAd(
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
// TODO: clean code
// ignore: unused_element
List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
      .map<TrufiLocation>(
          (Map<String, dynamic> json) => TrufiLocation.fromSearch(json))
      .toList() as List<TrufiLocation>;
}

PlanEntity _parsePlan(String responseBody) {
  return PlanEntity.fromJson(json.decode(responseBody) as Map<String, dynamic>);
}

AdEntity _parseAd(String responseBody) {
  return AdEntity.fromJson(json.decode(responseBody) as Map<String, dynamic>);
}
