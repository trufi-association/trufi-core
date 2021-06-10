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
  final GraphQLClient client = getClient();

  GraphQLPlanRepository();

  Future<Plan> fetchPlanSimple({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required List<TransportMode> transportsMode,
  }) async {
    final WatchQueryOptions listStopTimes = WatchQueryOptions(
      document: parseString(plan_queries.utilsSummarySimplePageQuery),
      variables: <String, dynamic>{
        'fromPlace': parsePlace(fromLocation),
        'toPlace': parsePlace(toLocation),
        'numItineraries': 5,
        'transportModes': parseTransportModes(transportsMode),
      },
      fetchResults: true,
    );
    final dataStopsTimes = await client.query(listStopTimes);
    if (dataStopsTimes.hasException && dataStopsTimes.data == null) {
      throw dataStopsTimes.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    final stopData =
        Plan.fromMap(dataStopsTimes.data['plan'] as Map<String, dynamic>);
    return stopData;
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
    final WatchQueryOptions listStopTimes = WatchQueryOptions(
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
        'numItineraries': 5,
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
        'locale': locale ?? 'en',
      },
      fetchResults: true,
    );
    final dataStopsTimes = await client.query(listStopTimes);
    if (dataStopsTimes.hasException && dataStopsTimes.data == null) {
      throw dataStopsTimes.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    final stopData = Plan.fromMap(
        dataStopsTimes.data['viewer']['plan'] as Map<String, dynamic>);
    return stopData;
  }

  Future<ModesTransport> fetchWalkBikePlanQuery({
    @required TrufiLocation fromLocation,
    @required TrufiLocation toLocation,
    @required PayloadDataPlanState advancedOptions,
    String locale,
  }) async {
    final linearDistance =
        estimateItineraryDistance(fromLocation.latLng, toLocation.latLng);
    final date = advancedOptions?.date ?? DateTime.now();

    final WatchQueryOptions listStopTimes = WatchQueryOptions(
      document: addFragments(
        parseString(walkbike_queries.summaryPageWalkBikeQuery),
        [
          plan_fragments.summaryPlanContainerPlanFragment,
          plan_fragments.itineraryTabPlanFragment,
          addFragments(plan_fragments.itineraryTabItineraryFragment,
              [plan_fragments.legAgencyInfoFragment]),
          addFragments(plan_fragments.summaryPlanContainerItinerariesFragment, [
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
        'triangle': OptimizeType.triangle.value,
        'itineraryFiltering': 1.5,
        'unpreferred': {'useUnpreferredRoutesPenalty': 1200},
        'locale': locale ?? 'en',
        'bikeAndPublicMaxWalkDistance':
            PayloadDataPlanState.bikeAndPublicMaxWalkDistance,
        'bikeAndPublicModes':
            parseBikeAndPublicModes(advancedOptions.transportModes),
        'bikeParkModes': parsebikeParkModes(advancedOptions.transportModes),
        'bikeandPublicDisableRemainingWeightHeuristic': false,
        'shouldMakeWalkQuery': !advancedOptions.wheelchair &&
            linearDistance < PayloadDataPlanState.maxWalkDistance,
        'shouldMakeBikeQuery': !advancedOptions.wheelchair &&
            linearDistance < PayloadDataPlanState.suggestBikeMaxDistance &&
            advancedOptions.includeBikeSuggestions,
        'shouldMakeCarQuery': advancedOptions.includeCarSuggestions &&
            linearDistance > PayloadDataPlanState.suggestCarMinDistance,
        'shouldMakeParkRideQuery':
            advancedOptions.includeParkAndRideSuggestions &&
                linearDistance > PayloadDataPlanState.suggestCarMinDistance,
        'shouldMakeOnDemandTaxiQuery': date.hour > 21 ||
            (date.hour == 21 && date.minute == 0) ||
            date.hour < 5 ||
            (date.hour == 5 && date.minute == 0),
        'showBikeAndParkItineraries': !advancedOptions.wheelchair &&
            advancedOptions.includeBikeSuggestions,
        'showBikeAndPublicItineraries': !advancedOptions.wheelchair &&
            advancedOptions.includeBikeSuggestions,
      },
      fetchResults: true,
    );
    final dataStopsTimes = await client.query(listStopTimes);
    if (dataStopsTimes.hasException && dataStopsTimes.data == null) {
      throw dataStopsTimes.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Internet no connection");
    }
    final stopData = ModesTransport.fromJson(dataStopsTimes.data);

    return stopData;
  }
}
