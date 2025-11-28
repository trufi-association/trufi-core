import 'package:graphql/client.dart';
import 'package:gql/language.dart';

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/repositories/plan_repository.dart';
import '../graphql/graphql_client_factory.dart';
import 'otp_queries.dart';
import 'otp_response_parser.dart';

/// Implementation of [PlanRepository] using OpenTripPlanner 2.7 GraphQL API.
class OtpPlanRepository implements PlanRepository {
  OtpPlanRepository({
    required String endpoint,
    this.useAdvancedQuery = true,
  }) : _client = GraphQLClientFactory.create(endpoint);

  final GraphQLClient _client;
  final bool useAdvancedQuery;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
  }) async {
    final queryString = useAdvancedQuery ? advancedTripQuery : simpleTripQuery;
    final query = QueryOptions(
      document: parseString(queryString),
      variables: <String, dynamic>{
        'from': from.toOtpLocation(),
        'to': to.toOtpLocation(),
        'numTripPatterns': numItineraries,
        if (locale != null) 'locale': locale,
      },
    );

    final result = await _client.query(query);

    if (result.hasException && result.data == null) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        throw OtpException(
          'Bad request: ${result.exception!.graphqlErrors.first.message}',
        );
      }
      throw OtpException('No internet connection');
    }

    // Handle eager cache responses
    if (result.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return OtpResponseParser.parseTrip(result.data!);
  }
}

/// Exception thrown by OTP operations.
class OtpException implements Exception {
  OtpException(this.message);

  final String message;

  @override
  String toString() => 'OtpException: $message';
}
