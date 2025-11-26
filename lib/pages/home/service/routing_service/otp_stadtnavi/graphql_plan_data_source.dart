import 'dart:async';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:gql/language.dart';

import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/service/graphql_client.dart';
import 'package:trufi_core/pages/home/service/i_plan_repository.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/otp_stadtnavi_models/plan.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/plan_fragment.dart'
    as plan_fragment;
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/plan_queries.dart'
    as plan_queries;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/graphql_utils.dart';

class StadtnaviGraphQLPlanDataSource extends IPlanRepository {
  final GraphQLClient client;

  StadtnaviGraphQLPlanDataSource(String endpoint)
    : client = getClient(endpoint);

  static const maxRetries = 5;
  String parsePlace(TrufiLocation location) {
    return "${location.description}::${location.position.latitude},${location.position.longitude}";
  }

  String parseTime(DateTime? date) {
    final tempDate = date ?? DateTime.now();
    return DateFormat('HH:mm:ss').format(tempDate);
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
      document: GraphqlUtils.addFragments(parseString(plan_queries.planQuery), [
        plan_fragment.itineraryPageViewer,
        plan_fragment.itineraryPageServiceTimeRange,
        // level 1
        plan_fragment.itineraryListContainerPlan,
        plan_fragment.itineraryDetailsPlan,
        plan_fragment.itineraryDetailsItinerary,
        plan_fragment.itineraryListContainerItineraries,
        plan_fragment.itineraryLineLegs,
        plan_fragment.routeLinePattern,
        // level 2
        plan_fragment.itineraryLineLegs,
        plan_fragment.routeLinePattern,
        plan_fragment.legAgencyInfoLeg,
        plan_fragment.itineraryListItineraries,
        // level 3
        plan_fragment.stopCardHeaderContainerStop,
      ]),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(fromLocation),
        'toPlace': parsePlace(toLocation),
        'time': parseTime(DateTime.now().copyWith(hour: 15)),
        'numItineraries': 10,
        'modes': [
          {"mode": "BUS"},
          {"mode": "CARPOOL"},
          {"mode": "FUNICULAR"},
          {"mode": "RAIL"},
          {"mode": "SUBWAY"},
          {"mode": "WALK"},
        ],
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
    final planData = PlanStadtnavi.fromMap(
      planAdvancedData.data!['viewer']['plan'] as Map<String, dynamic>,
    );
    return planData.toPlan();
  }

  static List<Map<String, String>> modesAsOTPModes(List<String> modes) {
    return modes.map((mode) {
      List<String> modeAndQualifier = mode.split("_");
      return modeAndQualifier.length > 1
          ? {"mode": modeAndQualifier[0], "qualifier": modeAndQualifier[1]}
          : {"mode": modeAndQualifier[0]};
    }).toList();
  }
}
