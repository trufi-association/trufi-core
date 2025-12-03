import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:gql/language.dart';

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/repositories/plan_repository.dart';
import '../graphql/graphql_client_factory.dart';
import 'otp_2_7_queries.dart';
import 'otp_2_7_response_parser.dart';

/// Implementation of [PlanRepository] using OpenTripPlanner 2.7 GraphQL API.
///
/// OTP 2.7 uses the standard OTP GraphQL schema with:
/// - `plan` query
/// - `itineraries` without emissions data (added in 2.8)
/// - Basic booking info support
/// - Location format: "name::lat,lon" string
/// - Times in milliseconds since epoch
class Otp27PlanRepository implements PlanRepository {
  Otp27PlanRepository({
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
  }) async {
    final queryString =
        useSimpleQuery ? otp27SimplePlanQuery : otp27PlanQuery;

    final query = QueryOptions(
      document: parseString(queryString),
      variables: <String, dynamic>{
        'fromPlace': _formatLocation(from),
        'toPlace': _formatLocation(to),
        'numItineraries': numItineraries,
        if (locale != null) 'locale': locale,
      },
    );

    final result = await _client.query(query);

    if (result.hasException && result.data == null) {
      debugPrint('OTP 2.7 fetchPlan error: ${result.exception}');
      if (result.exception!.graphqlErrors.isNotEmpty) {
        final error = result.exception!.graphqlErrors.first.message;
        debugPrint('OTP 2.7 GraphQL error: $error');
        throw Otp27Exception('Bad request: $error');
      }
      throw Otp27Exception('No internet connection');
    }

    // Handle eager cache responses
    if (result.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return Otp27ResponseParser.parsePlan(result.data!);
  }

  /// Formats a location for OTP 2.7.
  ///
  /// OTP 2.7 expects location in format: "name::lat,lon"
  String _formatLocation(RoutingLocation location) {
    final name = location.description.isNotEmpty
        ? location.description
        : 'Location';
    return '$name::${location.position.latitude},${location.position.longitude}';
  }
}

/// Exception thrown by OTP 2.7 operations.
class Otp27Exception implements Exception {
  Otp27Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp27Exception: $message';
}
