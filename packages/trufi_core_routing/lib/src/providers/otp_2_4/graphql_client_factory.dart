import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// Factory for creating GraphQL clients.
class GraphQLClientFactory {
  GraphQLClientFactory._();

  /// Default timeout for GraphQL requests.
  static const defaultTimeout = Duration(seconds: 60);

  /// Creates a GraphQL client for the given endpoint.
  ///
  /// [timeout] defaults to 60 seconds.
  /// [deviceIdService] defaults to [SharedPreferencesDeviceIdService] and is
  /// used to inject the `X-Device-Id` header on every outgoing request.
  static GraphQLClient create(
    String endpoint, {
    Duration timeout = defaultTimeout,
    DeviceIdService? deviceIdService,
  }) {
    final httpClient = _OtpHttpClient(
      http.Client(),
      timeout,
      deviceIdService ?? SharedPreferencesDeviceIdService(),
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

/// HTTP client wrapper that adds a timeout and injects the `X-Device-Id`
/// header read from a [DeviceIdService] on every outgoing request.
class _OtpHttpClient extends http.BaseClient {
  _OtpHttpClient(this._inner, this._timeout, this._deviceIdService);

  final http.Client _inner;
  final Duration _timeout;
  final DeviceIdService _deviceIdService;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final deviceId = await _deviceIdService.getDeviceId();
    if (deviceId.isNotEmpty) {
      request.headers['X-Device-Id'] = deviceId;
    }
    return _inner.send(request).timeout(_timeout);
  }

  @override
  void close() => _inner.close();
}
