import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/trufi_models.dart';

import '../request_manager.dart';
import 'plan_graphql_model.dart';
import 'queries.dart' as queries;

class OnlineGraphQLRepository implements RequestManager {
  final String graphQLEndPoint;

  OnlineGraphQLRepository({
    @required this.graphQLEndPoint,
  });

  @override
  CancelableOperation<Ad> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelableAd(to);
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(
        from, to, [TransportMode.car, TransportMode.walk]);
  }

  @override
  Future<List<TrufiPlace>> fetchLocations(
      FavoriteLocationsCubit favoriteLocationsCubit,
      LocationSearchBloc locationSearchBloc,
      String query,
      {int limit,
      String correlationId}) {
    // TODO: implement fetchLocations
    throw UnimplementedError();
  }

  @override
  CancelableOperation<Plan> fetchTransitPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchCancelablePlan(
        from, to, [TransportMode.transit, TransportMode.walk]);
  }

  CancelableOperation<Plan> _fetchCancelablePlan(
    TrufiLocation from,
    TrufiLocation to,
    List<TransportMode> transportModes,
  ) {
    return CancelableOperation.fromFuture(() async {
      Plan plan = await _fetchPlan(from, to, transportModes);
      if (plan.hasError) {
        plan = Plan.fromError(plan.error.message);
      }
      return plan;
    }());
  }

  CancelableOperation<Ad> _fetchCancelableAd(
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      final Ad ad = await _fetchAd(to);
      return ad;
    }());
  }

  Future<Plan> _fetchPlan(
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

  Future<Ad> _fetchAd(
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

  Plan _parsePlan(String body) {
    final planGraphQL = PlanGraphQl.fromJson(
      json.decode(body)["data"]["plan"] as Map<String, dynamic>,
    );
    return planGraphQL.toPlan();
  }
}
