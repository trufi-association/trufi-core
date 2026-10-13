import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// #1004: the Trufi Tec contract is a documented guess, so the URL, the
/// headers, the tolerant parser and every failure path are pinned here —
/// when the real contract arrives, these are the tests to update.
const _origin = TrufiLatLng(-17.3936, -66.1570);
final _now = DateTime.utc(2026, 10, 13, 10, 30);

const _request = VehicleEtaRequest(
  origin: _origin,
  routeIds: {'1:1185', '1:1132'},
);

TrufiTecEtaProvider _provider({
  required MockClient client,
  String endpoint = 'https://api.trufitec.example/v1',
  String? apiKey,
  Map<String, String> headers = const {},
  Duration timeout = const Duration(seconds: 1),
}) => TrufiTecEtaProvider(
  endpoint: endpoint,
  apiKey: apiKey,
  headers: headers,
  timeout: timeout,
  client: client,
  now: () => _now,
);

MockClient _answering(String body, {int status = 200}) =>
    MockClient((_) async => http.Response(body, status));

const _fullFixture = {
  'timestamp': '2026-10-13T10:30:02Z',
  'etas': [
    {
      'routeId': '1:1132',
      'etaSeconds': 240,
      'vehicleId': 'ANH-817',
      'distanceMeters': 1200,
      'stopId': 'S42',
      'timestamp': '2026-10-13T10:29:58Z',
    },
    {
      'routeId': '1:1185',
      'etaSeconds': 720,
      'vehicleId': 'ANH-002',
      'distanceMeters': 3100.5,
      'stopId': 'S42',
      'timestamp': 1791887398,
    },
  ],
};

void main() {
  group('TrufiTecEtaProvider.buildUri', () {
    final provider = _provider(client: _answering('{}'));

    test('targets /eta with origin and sorted comma-joined routes', () {
      final uri = provider.buildUri(_request);
      expect(uri.scheme, 'https');
      expect(uri.host, 'api.trufitec.example');
      expect(uri.path, '/v1/eta');
      expect(uri.queryParameters['lat'], '-17.3936');
      expect(uri.queryParameters['lon'], '-66.157');
      expect(
        uri.queryParameters['routes'],
        '1:1132,1:1185',
        reason: 'sorted so equal requests build equal URLs',
      );
      expect(uri.queryParameters.containsKey('stops'), isFalse);
    });

    test('adds sorted stops when the request carries them', () {
      final uri = provider.buildUri(
        const VehicleEtaRequest(
          origin: _origin,
          routeIds: {'1132'},
          stopIds: {'S9', 'S1'},
        ),
      );
      expect(uri.queryParameters['stops'], 'S1,S9');
    });

    test('a trailing slash on the endpoint does not double the separator', () {
      final uri = _provider(
        client: _answering('{}'),
        endpoint: 'https://api.trufitec.example/v1/',
      ).buildUri(_request);
      expect(uri.path, '/v1/eta');
    });
  });

  group('TrufiTecEtaProvider.fetchEtas headers', () {
    test('sends Accept and X-Api-Key, caller headers win', () async {
      http.Request? seen;
      final client = MockClient((request) async {
        seen = request;
        return http.Response('{"etas": []}', 200);
      });
      await _provider(
        client: client,
        apiKey: 'secret',
        headers: const {'Accept': 'application/vnd.trufitec+json'},
      ).fetchEtas(_request);

      expect(seen, isNotNull);
      expect(seen!.method, 'GET');
      expect(seen!.headers['X-Api-Key'], 'secret');
      expect(
        seen!.headers['Accept'],
        'application/vnd.trufitec+json',
        reason: 'caller headers override the defaults',
      );
    });

    test('omits X-Api-Key when no key is configured', () async {
      http.Request? seen;
      final client = MockClient((request) async {
        seen = request;
        return http.Response('{"etas": []}', 200);
      });
      await _provider(client: client).fetchEtas(_request);
      expect(seen!.headers.containsKey('X-Api-Key'), isFalse);
      expect(seen!.headers['Accept'], 'application/json');
    });
  });

  group('TrufiTecEtaProvider.parseSnapshot', () {
    test('reads the full fixture', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot(
        _fullFixture,
        now: _now,
      );
      expect(snapshot.source, TrufiTecEtaProvider.source);
      expect(snapshot.fetchedAt, DateTime.utc(2026, 10, 13, 10, 30, 2));
      expect(snapshot.etas, hasLength(2));

      final first = snapshot.etas[0];
      expect(first.routeId, '1:1132');
      expect(first.eta, const Duration(seconds: 240));
      expect(first.vehicleId, 'ANH-817');
      expect(first.distanceMeters, 1200);
      expect(first.stopId, 'S42');
      expect(first.timestamp, DateTime.utc(2026, 10, 13, 10, 29, 58));

      final second = snapshot.etas[1];
      expect(second.distanceMeters, 3100.5);
      expect(
        second.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1791887398 * 1000, isUtc: true),
        reason: 'epoch seconds are accepted for item timestamps',
      );
    });

    test('accepts etaMinutes as a numeric string and snake_case ids', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot({
        'etas': [
          {'route_id': 1132, 'etaMinutes': '4', 'vehicle_id': 7},
        ],
      }, now: _now);
      final eta = snapshot.etas.single;
      expect(eta.routeId, '1132', reason: 'numeric route ids become strings');
      expect(eta.eta, const Duration(minutes: 4));
      expect(eta.vehicleId, '7');
      expect(
        eta.timestamp,
        _now,
        reason: 'no item nor top-level timestamp → now',
      );
    });

    test('prefers etaSeconds over etaMinutes and accepts numeric strings', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot({
        'etas': [
          {'route': '7', 'eta_seconds': '90', 'etaMinutes': 10},
        ],
      }, now: _now);
      expect(snapshot.etas.single.eta, const Duration(seconds: 90));
    });

    test('skips items without a route or with a negative/missing eta', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot({
        'etas': [
          {'etaSeconds': 60},
          {'routeId': '', 'etaSeconds': 60},
          {'routeId': '1132', 'etaSeconds': -5},
          {'routeId': '1132'},
          {'routeId': '1185', 'etaSeconds': 'soon'},
          'garbage',
          {'routeId': '1481', 'etaSeconds': 30},
        ],
      }, now: _now);
      expect(snapshot.etas.map((e) => e.routeId), ['1481']);
    });

    test('missing etas list and timestamp → empty snapshot at now', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot({}, now: _now);
      expect(snapshot.etas, isEmpty);
      expect(snapshot.fetchedAt, _now);
    });

    test('top-level epoch milliseconds are recognised', () {
      final snapshot = TrufiTecEtaProvider.parseSnapshot({
        'timestamp': 1791887402000,
        'etas': [],
      }, now: _now);
      expect(
        snapshot.fetchedAt,
        DateTime.fromMillisecondsSinceEpoch(1791887402000, isUtc: true),
      );
    });
  });

  group('TrufiTecEtaProvider.fetchEtas', () {
    test('returns the parsed snapshot on 200', () async {
      final snapshot = await _provider(
        client: _answering(jsonEncode(_fullFixture)),
      ).fetchEtas(_request);
      expect(snapshot.etaForRoute('1132')?.eta, const Duration(seconds: 240));
    });

    test('non-2xx status → VehicleEtaException with the status', () {
      expect(
        _provider(
          client: _answering('upstream down', status: 503),
        ).fetchEtas(_request),
        throwsA(
          isA<VehicleEtaException>().having(
            (e) => e.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('non-JSON body → VehicleEtaException', () {
      expect(
        _provider(client: _answering('not json')).fetchEtas(_request),
        throwsA(isA<VehicleEtaException>()),
      );
    });

    test('JSON that is not an object → VehicleEtaException', () {
      expect(
        _provider(client: _answering('[1, 2]')).fetchEtas(_request),
        throwsA(isA<VehicleEtaException>()),
      );
    });

    test('client errors are wrapped with their cause', () {
      final client = MockClient(
        (_) async => throw http.ClientException('connection refused'),
      );
      expect(
        _provider(client: client).fetchEtas(_request),
        throwsA(
          isA<VehicleEtaException>().having(
            (e) => e.cause,
            'cause',
            isA<http.ClientException>(),
          ),
        ),
      );
    });

    test('a slow server trips the timeout', () {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('{"etas": []}', 200);
      });
      expect(
        _provider(
          client: client,
          timeout: const Duration(milliseconds: 50),
        ).fetchEtas(_request),
        throwsA(isA<VehicleEtaException>()),
      );
    });
  });
}
