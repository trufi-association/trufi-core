import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/online_graphql_repository/queries.dart' as queries;
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';

class OnlineGraphQLRepository implements RequestManager {
  static const String planPath = '/plan';
  final LocalRepository preferences;

  OnlineGraphQLRepository({
    @required this.preferences,
  });

  @override
  CancelableOperation<Ad> fetchAd(BuildContext context, TrufiLocation to) {
    return _fetchCancelableAd(context, to);
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
      BuildContext context, TrufiLocation from, TrufiLocation to) {
    return _fetchCancelablePlan(from, to, "TRANSIT,WALK");
  }

  @override
  Future<List<TrufiPlace>> fetchLocations(FavoriteLocationsBloc favoriteLocationsBloc,
      LocationSearchBloc locationSearchBloc, String query,
      {int limit, String correlationId}) {
    // TODO: implement fetchLocations
    throw UnimplementedError();
  }

  @override
  CancelableOperation<Plan> fetchTransitPlan(
      BuildContext context, TrufiLocation from, TrufiLocation to) {
    return _fetchCancelablePlan(from, to, "TRANSIT,WALK");
  }

  CancelableOperation<Plan> _fetchCancelablePlan(
    TrufiLocation from,
    TrufiLocation to,
    String mode,
  ) {
    return CancelableOperation.fromFuture(() async {
      Plan plan = await _fetchPlan(from, to, mode);
      if (plan.hasError) {
        // TODO implement translate for other errors 
         plan = Plan.fromError('GraphQL error: ${plan.error.toString()}');
      }
      return plan;
    }());
  }

  CancelableOperation<Ad> _fetchCancelableAd(
    BuildContext context,
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
    String mode,
  ) async {
    final Uri request = Uri.parse(
      TrufiConfiguration().url.otpEndpoint,
    );
    final queryPlan = queries.getPlan(
      fromLat: from.latitude,
      fromLon: from.longitude,
      toLat: to.latitude,
      toLon: to.longitude,
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
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<Ad> _fetchAd(
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
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody)["data"] as Map<String, dynamic>);
}