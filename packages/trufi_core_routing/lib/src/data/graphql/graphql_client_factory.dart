import 'package:graphql/client.dart';

/// Factory for creating GraphQL clients.
class GraphQLClientFactory {
  GraphQLClientFactory._();

  /// Default timeout for GraphQL requests.
  static const defaultTimeout = Duration(seconds: 30);

  /// Creates a GraphQL client for the given endpoint.
  ///
  /// [timeout] defaults to 30 seconds.
  static GraphQLClient create(
    String endpoint, {
    Duration timeout = defaultTimeout,
  }) {
    final httpLink = HttpLink(
      endpoint,
      defaultHeaders: {
        'Accept': 'application/json',
      },
    );

    // Add timeout link
    final timeoutLink = _TimeoutLink(timeout);

    return GraphQLClient(
      cache: GraphQLCache(
        store: InMemoryStore(),
        partialDataPolicy: PartialDataCachePolicy.accept,
      ),
      link: timeoutLink.concat(httpLink),
    );
  }
}

/// Custom link that adds timeout to requests.
class _TimeoutLink extends Link {
  _TimeoutLink(this.timeout);

  final Duration timeout;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return forward!(request).timeout(timeout);
  }
}
