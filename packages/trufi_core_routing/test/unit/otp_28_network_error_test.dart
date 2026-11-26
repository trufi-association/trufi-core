import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// trufi-lima#9: offline, the planner panel showed the raw exception text
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
  test('a refused connection is a RoutingNetworkException', () async {
    // Bind then close: the port is known to refuse connections.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close(force: true);
    final provider = Otp28RoutingProvider(
      endpoint: 'http://127.0.0.1:$port',
      deviceIdService: _FixedDeviceId(),
    );

    final error = await _planError(provider);

    expect(
      error,
      isA<RoutingNetworkException>(),
      reason: 'a link failure must not be reported as a server error',
    );
    expect(error, isA<Exception>());
  });
}
