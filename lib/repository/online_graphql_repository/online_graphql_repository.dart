import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';

class OnlineGraphQLRepository implements RequestManager {
  static const String planPath = '/plan';
  final LocalRepository preferences;
  final graphQLClient = GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink(
      TrufiConfiguration().url.otpEndpoint,
    ),
  );

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
    final _client = QueryOptions(
      document: gql(
        r'''
          query FetchPlan($fromLat: Float!, $fromLon: Float!, $toLat: Float!,$toLon: Float!){
            plan(
              from: {lat: $fromLat, lon:  $fromLon}
              to: {lat: $toLat, lon:  $toLon}
              numItineraries: 3
              ) {
                date,
                from{
                  name,
                  lon,
                  lat,
                  vertexType
                },
                to{
                  name,
                  lon,
                  lat,
                  vertexType,
                },
                itineraries {
                  duration,
                  startTime,
                  endTime,
                  walkTime,
                  waitingTime,
                  walkDistance,
                  elevationLost,
                  elevationGained,
                  legs{
                    startTime,
                    endTime,
                    departureDelay,
                    arrivalDelay,
                    realTime,
                    distance,
                    mode,
                    route{
                      url
                    },
                    interlineWithPreviousLeg,
                    from{
                  		name,
                  		lon,
                  		lat,
                  		vertexType,
                  		departureTime,
                    },
                    to{
                  		name,
                  		lon,
                  		lat,
                  		vertexType,
                  		departureTime,
                    },
                    legGeometry{
                    	points,
                      length
                    },
                    rentedBike,
                    transitLeg,
                    duration,
                    steps{
                      distance,
                      lon,
                      lat,
                      elevationProfile{
                        distance,
                        elevation
                      }
                    },
                  },
                }
              }
          }
        ''',
      ),
      variables: {
        'fromLat': from.latitude,
        'fromLon': from.longitude,
        'toLat': to.latitude,
        'toLon': to.longitude,
      },
    );

    final queryResult = await graphQLClient.query(_client);

    // final response = await _fetchRequest(request, body);
    if (!queryResult.hasException) {
      return compute(_parsePlan, queryResult.data);
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<Ad> _fetchAd(
    TrufiLocation to,
  ) async {
    return null;
  }
}

Plan _parsePlan(Map<String, dynamic> responseBody) {
  return Plan.fromJson(responseBody);
}
