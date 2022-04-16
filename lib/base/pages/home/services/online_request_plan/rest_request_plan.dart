import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:trufi_core/base/pages/home/services/request_plan_service.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';

class RestRequestPlanService implements RequestPlanService {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';
  final String otpEndpoint;

  RestRequestPlanService({
    required this.otpEndpoint,
  });

  @override
  Future<Plan> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required List<TransportMode> transportModes,
    String? localeName,
  }) {
    return _fetchPlan(from, to, transportModes);
  }

  Future<Plan> _fetchPlan(
    TrufiLocation from,
    TrufiLocation to,
    List<TransportMode> transportModes,
  ) async {
    final Uri request = Uri.parse(
      otpEndpoint + planPath,
    ).replace(queryParameters: {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": _todayMonthDayYear(),
      "time": '12:00:00',
      "numItineraries": "5",
      "mode": _parseTransportModes(transportModes),
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
    } else {
      throw FetchOnlineResponseException('Server Error');
    }
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    try {
      final packageInfoVersion = await PackageInfoPlatform.version();
      return await http.get(request, headers: {
        "User-Agent": "Trufi/$packageInfoVersion",
      });
    } on Exception catch (e) {
      throw FetchOnlineRequestException(e);
    }
  }

  String _todayMonthDayYear() {
    final today = DateTime.now();
    return "${today.month.toString().padLeft(2, '0')}-"
            "01-" +
        today.year.toString();
  }

  String _parseTransportModes(List<TransportMode> list) {
    return list.map((e) => e.name).join(",");
  }

  Plan _parsePlan(String responseBody) {
    return Plan.fromJson(json.decode(responseBody) as Map<String, dynamic>);
  }
}
