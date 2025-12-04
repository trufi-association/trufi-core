import 'package:graphql/client.dart';
import 'package:gql/language.dart';

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/repositories/plan_repository.dart';
import '../graphql/graphql_client_factory.dart';
import 'otp_2_4_queries.dart';
import 'otp_2_4_response_parser.dart';

/// Implementation of [PlanRepository] using OpenTripPlanner 2.4 GraphQL API.
///
/// OTP 2.4 uses the standard OTP GraphQL schema with:
/// - `plan` query (not `trip`)
/// - `itineraries` (not `tripPatterns`)
/// - `route` (not `line`)
/// - `agency` (not `authority`)
/// - Location format: "name::lat,lon" string
/// - Times in milliseconds since epoch
class Otp24PlanRepository implements PlanRepository {
  Otp24PlanRepository({
    required String endpoint,
    this.useSimpleQuery = false,
  }) : _client = GraphQLClientFactory.create(endpoint);

  final GraphQLClient _client;

  /// If true, uses the simple query with fewer parameters.
  final bool useSimpleQuery;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    DateTime? dateTime,
  }) async {
    final queryString =
        useSimpleQuery ? otp24SimplePlanQuery : otp24PlanQuery;

    final effectiveDateTime = dateTime ?? DateTime.now();
    final date = '${effectiveDateTime.year}-${effectiveDateTime.month.toString().padLeft(2, '0')}-${effectiveDateTime.day.toString().padLeft(2, '0')}';
    final time = '${effectiveDateTime.hour.toString().padLeft(2, '0')}:${effectiveDateTime.minute.toString().padLeft(2, '0')}';

    final query = QueryOptions(
      document: parseString(queryString),
      variables: <String, dynamic>{
        'fromPlace': _formatLocation(from),
        'toPlace': _formatLocation(to),
        'numItineraries': numItineraries,
        'date': date,
        'time': time,
        if (locale != null) 'locale': locale,
      },
    );

    final result = await _client.query(query);

    if (result.hasException && result.data == null) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        throw Otp24Exception(
          'Bad request: ${result.exception!.graphqlErrors.first.message}',
        );
      }
      throw Otp24Exception('No internet connection');
    }

    // Handle eager cache responses
    if (result.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return Otp24ResponseParser.parsePlan(result.data!);
  }

  /// Formats a location for OTP 2.4.
  ///
  /// OTP 2.4 expects location in format: "name::lat,lon"
  String _formatLocation(RoutingLocation location) {
    final name = location.description.isNotEmpty
        ? location.description
        : 'Location';
    return '$name::${location.position.latitude},${location.position.longitude}';
  }
}

/// Exception thrown by OTP 2.4 operations.
class Otp24Exception implements Exception {
  Otp24Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp24Exception: $message';
}
