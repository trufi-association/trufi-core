import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;

/// Factory for creating GraphQL clients.
class GraphQLClientFactory {
  GraphQLClientFactory._();

  /// Default timeout for GraphQL requests.
  static const defaultTimeout = Duration(seconds: 60);

  /// Creates a GraphQL client for the given endpoint.
  ///
  /// [timeout] defaults to 60 seconds.
  static GraphQLClient create(
    String endpoint, {
    Duration timeout = defaultTimeout,
  }) {
    // Create HTTP client with timeout
    final httpClient = _TimeoutHttpClient(http.Client(), timeout);

    final httpLink = HttpLink(
      endpoint,
      defaultHeaders: {
        'Accept': 'application/json',
      },
      httpClient: httpClient,
    );

    return GraphQLClient(
      cache: GraphQLCache(
        store: InMemoryStore(),
        partialDataPolicy: PartialDataCachePolicy.accept,
      ),
      link: httpLink,
      queryRequestTimeout: timeout,
    );
  }
}

/// HTTP client wrapper that adds timeout to all requests.
class _TimeoutHttpClient extends http.BaseClient {
  _TimeoutHttpClient(this._inner, this._timeout);

  final http.Client _inner;
  final Duration _timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(_timeout);
  }

  @override
  void close() => _inner.close();
}
