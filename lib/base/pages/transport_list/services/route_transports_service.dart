import 'package:gql/language.dart';
import 'package:graphql/client.dart';

import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/pages/transport_list/services/patter_queries.dart'
    as pattern_query;
import 'package:trufi_core/base/utils/graphql_client/graphql_client.dart';

class RouteTransportsServices {
  final GraphQLClient client;

  RouteTransportsServices(String endpoint) : client = getClient(endpoint);

  Future<List<PatternOtp>> fetchPatterns() async {
    final WatchQueryOptions listPatterns = WatchQueryOptions(
      document: parseString(pattern_query.allPatterns),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final dataListPatterns = await client.query(listPatterns);
    if (dataListPatterns.hasException && dataListPatterns.data == null) {
      throw dataListPatterns.exception!.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final patterns = dataListPatterns.data!['patterns']
        ?.map<PatternOtp>(
            (dynamic json) => PatternOtp.fromJson(json as Map<String, dynamic>))
        ?.toList() as List<PatternOtp>;

    return patterns;
  }

  Future<PatternOtp> fetchDataPattern(String idStop) async {
    final WatchQueryOptions pattern = WatchQueryOptions(
      document: parseString(pattern_query.dataPattern),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
      variables: <String, dynamic>{
        'id': idStop,
      },
    );
    final dataPattern = await client.query(pattern);
    if (dataPattern.hasException && dataPattern.data == null) {
      throw dataPattern.exception!.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final stopData = PatternOtp.fromJson(
        dataPattern.data!['pattern'] as Map<String, dynamic>);

    // For cities that don't use stops like Cochabamba (uses street intersection).
    // Workaround: remove the name of the adjacent stops that are repeated
    final newListStops = <Stop>[];
    if (stopData.stops != null && stopData.stops!.isNotEmpty) {
      newListStops.add(stopData.stops!.first);
      for (final stop in stopData.stops!) {
        if (stop.name != newListStops.last.name) {
          newListStops.add(stop);
        }
      }
    }

    return stopData.copyWith(stops: newListStops);
  }
}
