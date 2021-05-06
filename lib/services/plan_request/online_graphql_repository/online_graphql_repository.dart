import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/plan_enums.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';

import '../../../trufi_models.dart';
import '../request_manager.dart';
import 'plan_graphql_model.dart';
import 'queries.dart' as queries;

class OnlineGraphQLRepository implements RequestManager {
  final String graphQLEndPoint;

  OnlineGraphQLRepository({
    @required this.graphQLEndPoint,
  });

  @override
  Future<PlanEntity> fetchAdvancedPlan({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required String correlationId,
    SettingPanelState advancedOptions,
  }) async {
    if (advancedOptions == null) {
      return _fetchPlan(from, to, [TransportMode.transit, TransportMode.walk]);
    } else {
      return _fetchPlanAdvanced(
        from: from,
        to: to,
        advancedOptions: advancedOptions,
      );
    }
  }

  @override
  Future<AdEntity> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchAd(to);
  }

  @override
  Future<PlanEntity> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchPlan(from, to, [TransportMode.car, TransportMode.walk]);
  }

  Future<PlanEntity> _fetchPlan(
    TrufiLocation from,
    TrufiLocation to,
    List<TransportMode> transportModes,
  ) async {
    final Uri request = Uri.parse(
      graphQLEndPoint,
    );
    final queryPlan = queries.getCustomPlan(
      fromLat: from.latitude,
      fromLon: from.longitude,
      toLat: to.latitude,
      toLon: to.longitude,
      transportModes: transportModes,
    );
    final body = {
      "query": '''
        query {
          $queryPlan
        }
      '''
    };
    final response = await _fetchRequest(request, body);
    if (response.statusCode == 200) {
      return _parsePlan(utf8.decode(response.bodyBytes));
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<PlanEntity> _fetchPlanAdvanced({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required SettingPanelState advancedOptions,
  }) async {
    final Uri request = Uri.parse(
      graphQLEndPoint,
    );
    final queryPlan = queries.getPlanAdvanced(
      fromLat: from.latitude,
      fromLon: from.longitude,
      toLat: to.latitude,
      toLon: to.longitude,
      walkingSpeed: advancedOptions.typeWalkingSpeed,
      avoidWalking: advancedOptions.avoidWalking,
      transportModes: advancedOptions.transportModes,
      bikeRentalNetworks: advancedOptions.bikeRentalNetworks,
      walkBoardCost: advancedOptions.avoidTransfers
          ? WalkBoardCost.walkBoardCostHigh
          : WalkBoardCost.defaultCost,
      optimize: advancedOptions.includeBikeSuggestions ? OptimizeType.triangle : OptimizeType.quick,
      bikeSpeed: advancedOptions.typeBikingSpeed,
      wheelchair: advancedOptions.wheelchair,
    );
    
    final body = {
      "query": '''
        query {
          $queryPlan
        }
      '''
    };
    final response = await _fetchRequest(request, body);
    if (response.statusCode == 200) {
      return _parsePlan(utf8.decode(response.bodyBytes));
    } else {
      log(response.body);
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<AdEntity> _fetchAd(
    TrufiLocation to,
  ) async {
    return null;
  }

  Future<http.Response> _fetchRequest(Uri request, Map<String, String> body) async {
    try {
      return await http.post(request,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(body));
    } on Exception catch (e) {
      throw FetchOnlineRequestException(e);
    }
  }

  PlanEntity _parsePlan(String body) {
    final planGraphQL = PlanGraphQl.fromJson(
      json.decode(body)["data"]["plan"] as Map<String, dynamic>,
    );
    return planGraphQL.toPlan();
  }
}
