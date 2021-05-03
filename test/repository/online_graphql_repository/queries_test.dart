import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/queries.dart';

void main() {
  group("Queries", () {
    test("should return the query with the given parameters", () {
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
  });
}
