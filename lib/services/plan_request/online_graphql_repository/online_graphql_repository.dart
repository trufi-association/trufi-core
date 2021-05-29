import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import '../../../trufi_models.dart';
import '../request_manager.dart';
import 'graphql_plan_repository.dart';
import 'plan_graphql_model.dart';

class OnlineGraphQLRepository implements RequestManager {
  final String graphQLEndPoint;
  final GraphQLPlanRepository _graphQLPlanRepository = GraphQLPlanRepository();

  OnlineGraphQLRepository({
    @required this.graphQLEndPoint,
  });

  @override
  Future<PlanEntity> fetchAdvancedPlan({
    @required TrufiLocation from,
    @required TrufiLocation to,
    @required String correlationId,
    PayloadDataPlanState advancedOptions,
  }) async {
    if (advancedOptions == null) {
      return _fetchPlan(from, to, [TransportMode.transit, TransportMode.walk]);
    } else {
      return _fetchPlanAdvanced(
        from: from,
        to: to,
        advancedOptions: advancedOptions,
      );
    }
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
    final planEntityData = await _graphQLPlanRepository.fetchPlanSimple(
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
  }) async {
    PlanGraphQl planEntityData = await _graphQLPlanRepository.fetchPlanAdvanced(
      fromLocation: from,
      toLocation: to,
      advancedOptions: advancedOptions,
    );
    if (planEntityData.itineraries.isEmpty) {
      planEntityData = await _graphQLPlanRepository.fetchPlanAdvanced(
        fromLocation: from,
        toLocation: to,
        advancedOptions: advancedOptions,
        defaultFecth: true,
      );
    }
    return planEntityData.toPlan();
  }
}
