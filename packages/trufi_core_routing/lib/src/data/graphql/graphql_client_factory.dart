import 'package:graphql/client.dart';

/// Factory for creating GraphQL clients.
class GraphQLClientFactory {
  GraphQLClientFactory._();

  /// Creates a GraphQL client for the given endpoint.
  static GraphQLClient create(String endpoint) {
    final httpLink = HttpLink(endpoint);
    return GraphQLClient(
      cache: GraphQLCache(
        store: InMemoryStore(),
        partialDataPolicy: PartialDataCachePolicy.accept,
      ),
      link: httpLink,
    );
  }
}
