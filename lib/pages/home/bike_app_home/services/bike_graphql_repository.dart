import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/services/models_otp/enums/mode.dart';
import 'package:trufi_core/services/models_otp/plan.dart';
import 'package:trufi_core/services/plan_request/request_manager.dart';

import 'graphql_bike_plan_repository.dart';

class BikeGraphQLRepository implements RequestManager {
  final String graphQLEndPoint;
  final GraphqlBikePlanRepository _graphqlBikePlanRepository;

  BikeGraphQLRepository({
    @required this.graphQLEndPoint,
  }) : _graphqlBikePlanRepository = GraphqlBikePlanRepository(graphQLEndPoint);

  @override
  Future<PlanEntity> fetchAdvancedPlan({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required String correlationId,
    PayloadDataPlanState advancedOptions,
    String localeName,
  }) async {
    if (advancedOptions == null) {
      return _fetchPlan(from, to, [TransportMode.transit, TransportMode.walk]);
    } else {
      return _fetchPlanAdvanced(
          from: from,
          to: to,
          advancedOptions: advancedOptions,
          locale: localeName);
    }
  }

  @override
  Future<ModesTransportEntity> fetchTransportModePlan({
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
    PayloadDataPlanState advancedOptions,
    String localeName,
  }) {
    // TODO: implement fetchTransportModePlan
    throw UnimplementedError();
  }

  @override
  Future<PlanEntity> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return _fetchPlan(from, to, [TransportMode.car, TransportMode.walk]);
  }

  @override
  Future<AdEntity> fetchAd(TrufiLocation to, String correlationId) {
    // TODO: implement fetchAd
    throw UnimplementedError();
  }

  Future<PlanEntity> _fetchPlan(
    TrufiLocation from,
    TrufiLocation to,
    List<TransportMode> transportModes,
  ) async {
    final planEntityData = await _graphqlBikePlanRepository.fetchPlanSimple(
      fromLocation: from,
      toLocation: to,
      transportsMode: transportModes,
    );
    return planEntityData.toPlan();
  }

  Future<PlanEntity> _fetchPlanAdvanced({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required PayloadDataPlanState advancedOptions,
    @required String locale,
  }) async {
    Plan planData = await _graphqlBikePlanRepository.fetchPlanAdvanced(
      fromLocation: from,
      toLocation: to,
      advancedOptions: advancedOptions,
      locale: locale,
    );
    if (planData.itineraries.length > 1) {
      planData = planData.copyWith(
        itineraries: planData.itineraries
            .where(
              (itinerary) => !itinerary.legs.every(
                  (leg) => leg.mode == Mode.bicycle || leg.mode == Mode.walk),
            )
            .toList(),
      );
    }
    return planData.toPlan();
  }
}
