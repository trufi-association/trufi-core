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
    Future<String?> Function()? deviceIdProvider,
  }) {
    final httpClient = _OtpHttpClient(
      http.Client(),
      timeout,
      deviceIdProvider,
    );

    final httpLink = HttpLink(
      endpoint,
      defaultHeaders: {'Accept': 'application/json'},
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

/// HTTP client wrapper that adds a timeout and optionally injects the
/// `X-Device-Id` header into every outgoing request.
class _OtpHttpClient extends http.BaseClient {
  _OtpHttpClient(this._inner, this._timeout, this._deviceIdProvider);

  final http.Client _inner;
  final Duration _timeout;
  final Future<String?> Function()? _deviceIdProvider;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final provider = _deviceIdProvider;
    if (provider != null) {
      final deviceId = await provider();
      if (deviceId != null && deviceId.isNotEmpty) {
        request.headers['X-Device-Id'] = deviceId;
      }
    }
    return _inner.send(request).timeout(_timeout);
  }

  @override
  void close() => _inner.close();
}
