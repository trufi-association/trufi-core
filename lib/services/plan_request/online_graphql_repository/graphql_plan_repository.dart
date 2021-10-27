import 'dart:async';

import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:meta/meta.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/services/models_otp/plan.dart';

import 'graphql_client/graphql_client.dart';
import 'graphql_client/graphql_utils.dart';
import 'graphql_operation/fragments/plan_fragment.dart' as plan_fragment;
import 'graphql_operation/fragments/service_time_range_fragment.dart'
    as service_time_range_fragment;
import 'graphql_operation/queries/modes_plan_queries.dart'
    as modes_plan_queries;
import 'graphql_operation/queries/plan_queries.dart' as plan_queries;
import 'graphql_operation/query_utils.dart';
import 'modes_transport.dart';

class GraphQLPlanRepository {
  final GraphQLClient client;

  GraphQLPlanRepository(String endpoint) : client = getClient(endpoint);

  Future<Plan> fetchPlanSimple({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required List<TransportMode> transportsMode,
    @required String locale,
  }) async {
    final dateNow = DateTime.now();
    final QueryOptions planSimpleQuery = QueryOptions(
      document: addFragments(parseString(plan_queries.simplePlanQuery), [
        plan_fragment.planFragment,
        service_time_range_fragment.serviceTimeRangeFragment,
      ]),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(fromLocation),
        'toPlace': parsePlace(toLocation),
        'numItineraries': 5,
        'transportModes': parseTransportModes(transportsMode),
        "date": parseDateFormat(dateNow),
        'time': parseTime(dateNow),
        'locale': locale ?? 'de',
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final planSimpleData = await client.query(planSimpleQuery);
    if (planSimpleData.hasException && planSimpleData.data == null) {
      throw planSimpleData.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final planData = Plan.fromMap(
        planSimpleData.data['viewer']['plan'] as Map<String, dynamic>);
    return planData;
  }

  Future<Plan> fetchPlanAdvanced({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required PayloadDataPlanState advancedOptions,
    @required String locale,
    bool defaultFecth = false,
  }) async {
    final transportsMode =
        defaultFecth ? defaultTransportModes : advancedOptions.transportModes;
    final QueryOptions planAdvancedQuery = QueryOptions(
      document: addFragments(parseString(plan_queries.advancedPlanQuery), [
        plan_fragment.planFragment,
        service_time_range_fragment.serviceTimeRangeFragment,
      ]),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(fromLocation),
        'toPlace': parsePlace(toLocation),
        'intermediatePlaces': [],
        'numItineraries': 25,
        'transportModes': parseTransportModes(transportsMode),
        "date": parseDateFormat(advancedOptions.date),
        'time': parseTime(advancedOptions.date),
        'walkReluctance': advancedOptions.avoidWalking ? 5 : 2,
        'walkBoardCost': advancedOptions.avoidTransfers
            ? WalkBoardCost.walkBoardCostHigh.value
            : WalkBoardCost.defaultCost.value,
        'minTransferTime': 120,
        'walkSpeed': advancedOptions.typeWalkingSpeed.value,
        'maxWalkDistance': 15000,
        'wheelchair': advancedOptions.wheelchair,
        'ticketTypes': null,
        'disableRemainingWeightHeuristic':
            transportsMode.map((e) => e.name).contains('BICYCLE'),
        'arriveBy': advancedOptions.arriveBy,
        'transferPenalty': 0,
        'bikeSpeed': advancedOptions.typeBikingSpeed.value,
        'optimize': advancedOptions.includeBikeSuggestions
            ? OptimizeType.triangle.name
            : OptimizeType.quick.name,
        'triangle': advancedOptions.includeBikeSuggestions
            ? OptimizeType.triangle.value
            : OptimizeType.quick.value,
        'itineraryFiltering': 1.5,
        'unpreferred': {'useUnpreferredRoutesPenalty': 1200},
        'allowedBikeRentalNetworks':
            parseBikeRentalNetworks(advancedOptions.bikeRentalNetworks),
        'locale': locale ?? 'de',
      },
    );
    final planAdvancedData = await client.query(planAdvancedQuery);
    if (planAdvancedData.hasException && planAdvancedData.data == null) {
      throw planAdvancedData.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    if (planAdvancedData.source.isEager) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    final planData = Plan.fromMap(
        planAdvancedData.data['viewer']['plan'] as Map<String, dynamic>);
    return planData;
  }

  Future<ModesTransport> fetchModesPlanQuery({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required PayloadDataPlanState advancedOptions,
    @required String locale,
  }) async {
    final linearDistance =
        estimateDistance(fromLocation.latLng, toLocation.latLng);
    final dateNow = DateTime.now();
    final date = advancedOptions?.date ?? dateNow;
    final shouldMakeAllQuery = !advancedOptions.isFreeParkToCarPark &&
        !advancedOptions.isFreeParkToParkRide;

    final QueryOptions modesPlanQuery = QueryOptions(
        document: addFragments(
          parseString(modes_plan_queries.summaryModesPlanQuery),
          [plan_fragment.planFragment],
        ),
        variables: <String, dynamic>{
          'fromPlace': parsePlace(fromLocation),
          'toPlace': parsePlace(toLocation),
          'intermediatePlaces': [],
          'date': parseDateFormat(date),
          'time': parseTime(date),
          'walkReluctance': advancedOptions.avoidWalking ? 5 : 2,
          'walkBoardCost': advancedOptions.avoidTransfers
              ? WalkBoardCost.walkBoardCostHigh.value
              : WalkBoardCost.defaultCost.value,
          'minTransferTime': 120,
          'walkSpeed': advancedOptions.typeWalkingSpeed.value,
          'wheelchair': advancedOptions.wheelchair,
          'ticketTypes': null,
          'disableRemainingWeightHeuristic': advancedOptions.transportModes
              .map((e) => '${e.name}_${e.qualifier ?? ''}')
              .contains('BICYCLE_RENT'),
          'arriveBy': advancedOptions.arriveBy,
          'transferPenalty': 0,
          'bikeSpeed': advancedOptions.typeBikingSpeed.value,
          'optimize': advancedOptions.includeBikeSuggestions
              ? OptimizeType.triangle.name
              : OptimizeType.greenWays.name,
          'triangle': {...OptimizeType.triangle.value},
          'itineraryFiltering': 1.5,
          'unpreferred': {'useUnpreferredRoutesPenalty': 1200},
          'locale': locale ?? 'de',
          'bikeAndPublicMaxWalkDistance':
              PayloadDataPlanState.bikeAndPublicMaxWalkDistance,
          'bikeAndPublicModes':
              parseBikeAndPublicModes(advancedOptions.transportModes),
          'bikeParkModes': parsebikeParkModes(advancedOptions.transportModes),
          'carMode': parseCarMode(toLocation.latLng),
          'bikeandPublicDisableRemainingWeightHeuristic': false,
          'shouldMakeWalkQuery': shouldMakeAllQuery &&
              !advancedOptions.wheelchair &&
              linearDistance < PayloadDataPlanState.maxWalkDistance,
          'shouldMakeBikeQuery': shouldMakeAllQuery &&
              !advancedOptions.wheelchair &&
              linearDistance < PayloadDataPlanState.suggestBikeMaxDistance &&
              advancedOptions.includeBikeSuggestions,
          'shouldMakeCarQuery':
              (advancedOptions.isFreeParkToCarPark || shouldMakeAllQuery) &&
                  advancedOptions.includeCarSuggestions &&
                  linearDistance > PayloadDataPlanState.suggestCarMinDistance,
          'shouldMakeParkRideQuery':
              (advancedOptions.isFreeParkToParkRide || shouldMakeAllQuery) &&
                  advancedOptions.includeParkAndRideSuggestions &&
                  linearDistance > PayloadDataPlanState.suggestCarMinDistance,
          'shouldMakeOnDemandTaxiQuery': shouldMakeAllQuery && date.hour > 21 ||
              (date.hour == 21 && date.minute == 0) ||
              date.hour < 5 ||
              (date.hour == 5 && date.minute == 0),
          'showBikeAndParkItineraries': shouldMakeAllQuery &&
              !advancedOptions.wheelchair &&
              advancedOptions.includeBikeSuggestions,
          'showBikeAndPublicItineraries': shouldMakeAllQuery &&
              !advancedOptions.wheelchair &&
              advancedOptions.includeBikeSuggestions,
          'useVehicleParkingAvailabilityInformation':
              date.difference(dateNow).inMinutes <= 15,
          'bannedVehicleParkingTags': shouldMakeAllQuery
              ? PayloadDataPlanState.parkAndRideBannedVehicleParkingTags
              : [
                  'state:few',
                  ...PayloadDataPlanState.parkAndRideBannedVehicleParkingTags
                ],
        });
    final modesPlanData = await client.query(modesPlanQuery);
    if (modesPlanData.hasException && modesPlanData.data == null) {
      throw modesPlanData.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final modesTransportData = ModesTransport.fromJson(modesPlanData.data);

    return modesTransportData;
  }
}
