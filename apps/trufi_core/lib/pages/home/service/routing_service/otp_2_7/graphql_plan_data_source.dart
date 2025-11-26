import 'dart:async';

import 'package:graphql/client.dart';

import 'package:gql/language.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/service/graphql_client.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_2_7/grapqhql_queries/otp_schema_models_v2_7.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_2_7/grapqhql_queries/plan_queries_otp2_7.dart';
import 'package:trufi_core/pages/home/service/i_plan_repository.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class GraphQLPlanDataSource extends IPlanRepository {
  final GraphQLClient client;

  GraphQLPlanDataSource(String endpoint) : client = getClient(endpoint);

  Map<String, dynamic> _convertToOtpLocation(TrufiLocation location) {
    return {
      "coordinates": {
        "latitude": location.position.latitude,
        "longitude": location.position.longitude,
      },
      "name": location.description,
    };
  }

  @override
  Future<PlanEntity> fetchPlanAdvanced({
    required TrufiLocation fromLocation,
    required TrufiLocation toLocation,
    int numItineraries = 10,
    String? locale,
    bool defaultFecth = false,
    bool useDefaultModes = false,
  }) async {
    final QueryOptions planAdvancedQuery = QueryOptions(
      document: parseString(advancedPlanQuery2_7),
      variables: <String, dynamic>{
        'from': _convertToOtpLocation(fromLocation),
        'to': _convertToOtpLocation(toLocation),
      },
    );
    final planAdvancedData = await client.query(planAdvancedQuery);
    if (planAdvancedData.hasException && planAdvancedData.data == null) {
      throw planAdvancedData.exception!.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    if (planAdvancedData.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    final planData =
        Trip.fromJson(planAdvancedData.data!["trip"] as Map<String, dynamic>);
    return planData.toUIModel();
  }
}
