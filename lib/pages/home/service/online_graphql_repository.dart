import 'package:trufi_core/models/enums/mode.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/service/i_plan_repository.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_2_7/graphql_plan_data_source.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class OnlineGraphQLRepository {
  final String graphQLEndPoint;
  final IPlanRepository _graphQLPlanRepository;

  OnlineGraphQLRepository({
    required this.graphQLEndPoint,
  }) : _graphQLPlanRepository = GraphQLPlanDataSource(graphQLEndPoint);

  Future<PlanEntity> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required String localeName,
  }) async {
    PlanEntity planData = await _graphQLPlanRepository.fetchPlanAdvanced(
      fromLocation: from,
      toLocation: to,
      locale: localeName,
    );
    planData = planData.copyWith(
      itineraries: planData.itineraries
          ?.where(
            (itinerary) =>
                !(itinerary.legs).every((leg) => leg.mode == Mode.walk.name),
          )
          .toList(),
    );
    final mainFetchIsEmpty = planData.itineraries?.isEmpty ?? true;
    if (mainFetchIsEmpty) {
      planData = await _graphQLPlanRepository.fetchPlanAdvanced(
        fromLocation: from,
        toLocation: to,
        locale: localeName,
        useDefaultModes: true,
      );
    }
    planData = planData.copyWith(
      itineraries: planData.itineraries
          ?.where(
            (itinerary) =>
                !(itinerary.legs).every((leg) => leg.mode == Mode.walk.name),
          )
          .toList(),
    );
    PlanEntity planEntity = planData.copyWith();

    return planEntity;
  }

  Future<PlanEntity> fetchMoreItineraries({
    required TrufiLocation from,
    required TrufiLocation to,
    required String localeName,
  }) async {
    PlanEntity planData = await _graphQLPlanRepository.fetchPlanAdvanced(
      fromLocation: from,
      toLocation: to,
      locale: localeName,
      numItineraries: 5,
    );
    planData = planData.copyWith(
      itineraries: planData.itineraries
          ?.where(
            (itinerary) =>
                !(itinerary.legs).every((leg) => leg.mode == Mode.walk.name),
          )
          .toList(),
    );

    return planData;
  }
}
