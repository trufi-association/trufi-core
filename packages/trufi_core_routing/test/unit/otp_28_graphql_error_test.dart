import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// trufi-lima#9 (AC2): a GraphQL/server error answer is not a network failure
/// and is never shown raw. Already true today; guards the new typed split.
/// (offline, the planner panel showed the raw exception text
/// ("Otp28Exception: Network error: ClientException ... lima.trufi.dev ...").
/// The provider must tell a link failure from a server answer with a typed
/// exception, so the UI can pick the string. Loopback only: a closed port is
/// the offline case, a local server scripts the answers.
class _FixedDeviceId implements DeviceIdService {
  @override
  Future<String> getDeviceId() async => 'test-device';
}

final _from = RoutingLocation(
  description: 'A',
  position: const LatLng(-12.05, -77.04),
);
final _to = RoutingLocation(
  description: 'B',
  position: const LatLng(-12.10, -77.00),
);

Future<Object?> _planError(Otp28RoutingProvider provider) async {
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

void main() {
  test('a GraphQL error answer stays an Otp28Exception, not a network one',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      await request.drain<void>();
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'errors': [
              {'message': 'PlanFailure at lima.trufi.dev'},
            ],
          }),
        );
      await request.response.close();
    });
    final provider = Otp28RoutingProvider(
      endpoint: 'http://127.0.0.1:${server.port}',
      deviceIdService: _FixedDeviceId(),
    );

    final error = await _planError(provider);

    expect(error, isA<Otp28Exception>());
    expect(
      error.runtimeType.toString(),
      isNot('RoutingNetworkException'),
      reason: 'the server answered: the rider is online',
    );
  });
}
