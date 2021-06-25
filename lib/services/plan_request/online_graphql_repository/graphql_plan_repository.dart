import 'dart:async';
import 'package:meta/meta.dart';

import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/services/models_otp/plan.dart';

import 'graphql_client/graphql_client.dart';
import 'graphql_client/graphql_utils.dart';
import 'graphql_operation/fragments/utils_summary_plan_fragments.dart'
    as plan_fragments;
import 'graphql_operation/queries/utils_summary_plan_queries.dart'
    as plan_queries;
import 'graphql_operation/queries/walkbike_plan_queries.dart'
    as walkbike_queries;
import 'graphql_operation/query_utils.dart';
import 'modes_transport.dart';

class GraphQLPlanRepository {
  final GraphQLClient client;

  GraphQLPlanRepository(String endpoint) : client = getClient(endpoint);

  Future<Plan> fetchPlanSimple({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required List<TransportMode> transportsMode,
  }) async {
    final QueryOptions planSimpleQuery = QueryOptions(
      document: parseString(plan_queries.utilsSummarySimplePageQuery),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(fromLocation),
        'toPlace': parsePlace(toLocation),
        'numItineraries': 5,
        'transportModes': parseTransportModes(transportsMode),
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final planSimpleData = await client.query(planSimpleQuery);
    if (planSimpleData.hasException && planSimpleData.data == null) {
      throw planSimpleData.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    final planData =
        Plan.fromMap(planSimpleData.data['plan'] as Map<String, dynamic>);
    return planData;
  }

  Future<Plan> fetchPlanAdvanced({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required PayloadDataPlanState advancedOptions,
    String locale,
    bool defaultFecth = false,
  }) async {
    final transportsMode =
        defaultFecth ? defaultTransportModes : advancedOptions.transportModes;
    final QueryOptions planAdvancedQuery = QueryOptions(
      document: addFragments(parseString(plan_queries.utilsSummaryPageQuery), [
        addFragments(plan_fragments.summaryPageViewerFragment, [
          plan_fragments.summaryPlanContainerPlanFragment,
          plan_fragments.itineraryTabPlanFragment,
          addFragments(plan_fragments.itineraryTabItineraryFragment,
              [plan_fragments.legAgencyInfoFragment]),
          addFragments(plan_fragments.summaryPlanContainerItinerariesFragment, [
            plan_fragments.itinerarySummaryListFragment,
            plan_fragments.itineraryLineLegsFragment,
            addFragments(plan_fragments.routeLinePatternFragment,
                [plan_fragments.stopCardStopFragment]),
          ]),
          plan_fragments.itineraryLineLegsFragment,
          addFragments(plan_fragments.routeLinePatternFragment, [
            plan_fragments.stopCardStopFragment,
          ]),
        ]),
        plan_fragments.summaryPageServiceTimeRangeFragment,
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
          : Exception("Internet no connection");
    }
    if (planAdvancedData.source.isEager) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    final planData = Plan.fromMap(
        planAdvancedData.data['viewer']['plan'] as Map<String, dynamic>);
    return planData;
  }

  Future<ModesTransport> fetchWalkBikePlanQuery({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required PayloadDataPlanState advancedOptions,
    String locale,
  }) async {
    final linearDistance =
        estimateDistance(fromLocation.latLng, toLocation.latLng);
    final dateNow = DateTime.now();
    final date = advancedOptions?.date ?? dateNow;
    final shouldMakeAllQuery = !advancedOptions.isFreeParkToCarPark &&
        !advancedOptions.isFreeParkToParkRide;

    final QueryOptions walkBikePlanQuery = QueryOptions(
        document: addFragments(
          parseString(walkbike_queries.summaryPageWalkBikeQuery),
          [
            plan_fragments.summaryPlanContainerPlanFragment,
            plan_fragments.itineraryTabPlanFragment,
            addFragments(plan_fragments.itineraryTabItineraryFragment,
                [plan_fragments.legAgencyInfoFragment]),
            addFragments(
                plan_fragments.summaryPlanContainerItinerariesFragment, [
              plan_fragments.itinerarySummaryListFragment,
              plan_fragments.itineraryLineLegsFragment,
              addFragments(plan_fragments.routeLinePatternFragment,
                  [plan_fragments.stopCardStopFragment])
            ]),
            plan_fragments.itineraryLineLegsFragment,
            addFragments(plan_fragments.routeLinePatternFragment,
                [plan_fragments.stopCardStopFragment])
          ],
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
          'bannedVehicleParkingTags': shouldMakeAllQuery ? [] : ['state:few'],
        });
    final walkBikePlanData = await client.query(walkBikePlanQuery);
    if (walkBikePlanData.hasException && walkBikePlanData.data == null) {
      throw walkBikePlanData.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    final modesTransportData = ModesTransport.fromJson(walkBikePlanData.data);

    return modesTransportData;
  }
}
