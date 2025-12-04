// ignore: depend_on_referenced_packages
import 'package:gql/language.dart';
import 'package:graphql/client.dart';

import '../../domain/entities/stop.dart';
import '../../domain/entities/transit_route.dart';
import '../../domain/repositories/transit_route_repository.dart';
import '../graphql/graphql_client_factory.dart';
import 'otp_2_4_pattern_queries.dart' as queries;

/// OTP 2.4 implementation of [TransitRouteRepository].
class Otp24TransitRouteRepository implements TransitRouteRepository {
  final GraphQLClient _client;

  Otp24TransitRouteRepository(String endpoint)
      : _client = GraphQLClientFactory.create(endpoint);

  /// Creates a repository with a custom GraphQL client (for testing).
  Otp24TransitRouteRepository.withClient(this._client);

  @override
  Future<List<TransitRoute>> fetchPatterns() async {
    final options = WatchQueryOptions(
      document: parseString(queries.allPatterns),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException && result.data == null) {
      throw result.exception!.graphqlErrors.isNotEmpty
          ? Exception('Bad request')
          : Exception('Connection error');
    }

    final patterns = result.data!['patterns']
        ?.map<TransitRoute>((dynamic json) =>
            TransitRoute.fromJson(json as Map<String, dynamic>))
        ?.toList() as List<TransitRoute>;

    return patterns;
  }

  @override
  Future<TransitRoute> fetchPatternById(String id) async {
    final options = WatchQueryOptions(
      document: parseString(queries.patternById),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
      variables: <String, dynamic>{'id': id},
    );

    final result = await _client.query(options);

    if (result.hasException && result.data == null) {
      throw result.exception!.graphqlErrors.isNotEmpty
          ? Exception('Bad request')
          : Exception('Connection error');
    }

    final patternData =
        TransitRoute.fromJson(result.data!['pattern'] as Map<String, dynamic>);

    // For cities that don't use stops like Cochabamba (uses street intersection).
    // Workaround: remove the name of the adjacent stops that are repeated.
    final newListStops = <Stop>[];
    if (patternData.stops != null && patternData.stops!.isNotEmpty) {
      newListStops.add(patternData.stops!.first);
      for (final stop in patternData.stops!) {
        if (stop.name != newListStops.last.name) {
          newListStops.add(stop);
        }
      }
    }

    return patternData.copyWith(stops: newListStops);
  }
}
