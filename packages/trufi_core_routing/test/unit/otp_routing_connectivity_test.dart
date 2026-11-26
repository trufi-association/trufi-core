import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Which failures count as "no connection" (trufi-lima#9): only a
/// SocketException or a ClientException. A timeout, a TLS failure or any
/// HTTP answer is a generic error. Loopback servers only.
class _FixedDeviceId implements DeviceIdService {
  @override
  Future<String> getDeviceId() async => 'test-device';
}

class _MockHttpClient extends Mock implements http.Client {}

final _from = RoutingLocation(
  description: 'A',
  position: const LatLng(-12.05, -77.04),
);
final _to = RoutingLocation(
  description: 'B',
  position: const LatLng(-12.10, -77.00),
);

Future<Object?> _planError(IRoutingProvider provider) async {
  try {
    await provider.fetchPlan(
      from: _from,
      to: _to,
      dateTime: DateTime(2026, 11, 26, 12),
    );
  } catch (e) {
    return e;
  }
  return null;
}

Future<HttpServer> _serve(int status, ContentType type, String body) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((request) async {
    await request.drain<void>();
    request.response
      ..statusCode = status
      ..headers.contentType = type
      ..write(body);
    await request.response.close();
  });
  return server;
}

Future<int> _closedPort() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;
  await server.close(force: true);
  return port;
}

void main() {
  group('OTP 2.8', () {
    Otp28RoutingProvider provider(HttpServer server) => Otp28RoutingProvider(
      endpoint: 'http://127.0.0.1:${server.port}',
      deviceIdService: _FixedDeviceId(),
    );

    test('a 502 with an HTML body is an Otp28Exception', () async {
      final server = await _serve(
        502,
        ContentType.html,
        '<html><body>Bad Gateway</body></html>',
      );

      final error = await _planError(provider(server));

      expect(error, isA<Otp28Exception>());
      expect(error, isNot(isA<RoutingNetworkException>()));
    });

    test('a 500 with a JSON body is an Otp28Exception', () async {
      final server = await _serve(500, ContentType.json, '{"error":"boom"}');

      final error = await _planError(provider(server));

      expect(error, isA<Otp28Exception>());
      expect(error, isNot(isA<RoutingNetworkException>()));
    });
  });

  group('OTP 2.4', () {
    test('a refused connection is a RoutingNetworkException', () async {
      final port = await _closedPort();
      final provider = Otp24RoutingProvider(
        endpoint: 'http://127.0.0.1:$port',
        deviceIdService: _FixedDeviceId(),
      );

      expect(await _planError(provider), isA<RoutingNetworkException>());
    });

    test('a 500 answer is an Otp24Exception', () async {
      final server = await _serve(500, ContentType.json, '{"error":"boom"}');
      final provider = Otp24RoutingProvider(
        endpoint: 'http://127.0.0.1:${server.port}',
        deviceIdService: _FixedDeviceId(),
      );

      final error = await _planError(provider);

      expect(error, isA<Otp24Exception>());
    });
  });

  group('OTP 1.5', () {
    late _MockHttpClient client;
    late Otp15RoutingProvider provider;

    setUpAll(() => registerFallbackValue(Uri.parse('https://example.com')));

    setUp(() {
      client = _MockHttpClient();
      provider = Otp15RoutingProvider(
        endpoint: 'https://test-otp.example.com/otp/routers/default/plan',
        httpClient: client,
      );
    });

    tearDown(() => provider.dispose());

    test('a SocketException is a RoutingNetworkException', () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenThrow(const SocketException('Network is unreachable'));

      expect(await _planError(provider), isA<RoutingNetworkException>());
    });

    test('a timeout is not a RoutingNetworkException', () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenThrow(TimeoutException('slow'));

      final error = await _planError(provider);

      expect(error, isA<TimeoutException>());
      expect(error, isNot(isA<RoutingNetworkException>()));
    });
  });

  group('isConnectivityFailure', () {
    test('only a socket or client exception counts', () {
      expect(isConnectivityFailure(const SocketException('x')), isTrue);
      expect(isConnectivityFailure(http.ClientException('x')), isTrue);
      expect(isConnectivityFailure(TimeoutException('x')), isFalse);
      expect(isConnectivityFailure(const HandshakeException('x')), isFalse);
      expect(isConnectivityFailure(null), isFalse);
    });
  });
}
