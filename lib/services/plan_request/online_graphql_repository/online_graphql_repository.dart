import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
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
  CancelableOperation<AdEntity> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelableAd(to);
  }

  @override
  CancelableOperation<PlanEntity> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(
        from, to, [TransportMode.car, TransportMode.walk]);
  }

  @override
  CancelableOperation<PlanEntity> fetchTransitPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(
        from, to, [TransportMode.transit, TransportMode.walk]);
  }

  CancelableOperation<PlanEntity> _fetchCancelablePlan(
    TrufiLocation from,
    TrufiLocation to,
    List<TransportMode> transportModes,
  ) {
    return CancelableOperation.fromFuture(() async {
      PlanEntity plan = await _fetchPlan(from, to, transportModes);
      if (plan.hasError) {
        plan = PlanEntity.fromError(plan.error.message);
      }
      return plan;
    }());
  }

  CancelableOperation<AdEntity> _fetchCancelableAd(
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      final AdEntity ad = await _fetchAd(to);
      return ad;
    }());
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

  Future<AdEntity> _fetchAd(
    TrufiLocation to,
  ) async {
    return null;
  }

  Future<http.Response> _fetchRequest(
      Uri request, Map<String, String> body) async {
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
