import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/models/enums/plan_enums.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/queries.dart';

void main() {
  group("Queries", () {
    test("should return the query with the given parameters for getCustomPlan", () {
      final String result = getCustomPlan(
        fromLat: 1.2,
        fromLon: 88.1,
        toLat: 99.1,
        toLon: 99.9,
      );
      expect(result, contains("{lat: 1.2"));
      expect(result, contains("lon:  88.1}"));
      expect(result, contains("to: {lat: 99.1"));
      expect(result, contains("lon:  99.9}"));
      expect(result.length, 754);
    });

    test("should return the query with the given parameters for getPlanAdvanced", () {
      final String result = getPlanAdvanced(
        fromLat: 1.2,
        fromLon: 88.1,
        toLat: 99.1,
        toLon: 99.9,
        avoidWalking: true,
        arriveBy: true,
        itineraryFiltering: 2.5,
        maxWalkDistance: 10000,
        minTransferTime: 100,
        transferPenalty: 1,
        locale: "de",
        transportModes: [TransportMode.bus],
        bikeRentalNetworks: [BikeRentalNetwork.carSharing],
        optimize: OptimizeType.triangle,
        walkBoardCost: WalkBoardCost.walkBoardCostHigh,
        walkingSpeed: WalkingSpeed.calm,
      );
      expect(result, contains("{lat: 1.2"));
      expect(result, contains("lon:  88.1}"));
      expect(result, contains("to: {lat: 99.1"));
      expect(result, contains("lon:  99.9}"));
      expect(result, contains("arriveBy: true"));
      expect(result, contains("walkReluctance: 5"));
      expect(result, contains("wheelchair: false"));
      expect(result, contains("itineraryFiltering: 2.5"));
      expect(result, contains("minTransferTime: 100"));
      expect(result, contains("transferPenalty: 1"));
      expect(result, contains('locale: "de"'));
      expect(result, contains("maxWalkDistance: 10000"));
      expect(result, contains("transportModes: [{mode:BUS}]"));
      expect(result, contains('allowedBikeRentalNetworks: ["car-sharing"]'));
      expect(result, contains("triangle: {safetyFactor: 0.4, slopeFactor: 0.3, timeFactor: 0.3}"));
      expect(result, contains("walkBoardCost: ${WalkBoardCost.walkBoardCostHigh.value}"));
      expect(result, contains("walkSpeed: ${WalkingSpeed.calm.value}"));
      expect(result.length, 1310);
    });
  });
}
