import 'dart:async';

import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/services/request_plan_service.dart';
import 'package:trufi_core/base/utils/graphql_client/graphql_client.dart';
import 'package:trufi_core/base/utils/graphql_client/graphql_utils.dart';
import 'package:trufi_core/base/pages/home/services/online_request_plan/graphq_request_plan/plan_fragment.dart'
    as plan_fragment;
import 'package:trufi_core/base/pages/home/services/online_request_plan/graphq_request_plan/plan_queries.dart'
    as plan_queries;

class GraphqlRequestPlan implements RequestPlanService {
  final GraphQLClient client;

  GraphqlRequestPlan(String endpoint) : client = getClient(endpoint);

  @override
  Future<Plan> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required List<TransportMode> transportModes,
    bool? enableDebugOutput,
    String? localeName,
  }) async {
    final currentDate = DateTime.now().copyWith(
      // month: 2,
      // day: 4,
      hour: 11,
      minute: 0,
      second: 0,
    );
    final QueryOptions planAdvancedQuery = QueryOptions(
      document: addFragments(parseString(plan_queries.simplePlanQuery), [
        plan_fragment.planFragment,
      ]),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(from),
        'toPlace': parsePlace(to),
        'numItineraries': 20,
        "date": parseDateFormat(currentDate),
        'time': parseTime(currentDate),
        'debugItineraryFilter': enableDebugOutput ?? false,
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
    final planData = _parsePlan(planAdvancedData.data!['viewer']);
    return planData;
  }

  Plan _parsePlan(Map<String, dynamic> responseBody) {
    final plan = Plan.fromJson(responseBody);

    plan.itineraries?.sort((a, b) {
      // First criterion: Transfers (minor)
      int transfersComparison = a.transfers.compareTo(b.transfers);
      if (transfersComparison != 0) return transfersComparison;

      // Second criterion: Distance (minor)
      int distanceComparison = a.distance.compareTo(b.distance);
      if (distanceComparison != 0) return distanceComparison;

      // Third criterion: Duration (minor)
      int durationComparison = a.duration.compareTo(b.duration);
      if (durationComparison != 0) return durationComparison;

      // Fourth criterion: Walk Distance (minor)
      return a.walkDistance.compareTo(b.walkDistance);
    });

    return plan;
  }

  String _todayMonthDayYear() {
    final today = DateTime.now();
    return "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
  }

  String parsePlace(TrufiLocation location) {
    return "${location.description}::${location.latitude},${location.longitude}";
  }

  List<Map<String, String?>> parseTransportModes(List<TransportMode> list) {
    final dataParse = list
        .map((e) => <String, String?>{
              'mode': e.name,
            })
        .toList();
    return dataParse;
  }

  String parseDateFormat(DateTime? date) {
    final tempDate = date ?? DateTime.now();
    return DateFormat('MM-dd-yyyy').format(tempDate);
  }

  String parseTime(DateTime? date) {
    final tempDate = date ?? DateTime.now();
    return DateFormat('h:mm a').format(tempDate);
  }
}
