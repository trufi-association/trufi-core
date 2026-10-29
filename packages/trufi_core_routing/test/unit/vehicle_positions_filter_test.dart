import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:gql/language.dart' show printNode;
import 'package:graphql/client.dart';
import 'package:trufi_core_routing/src/services/vehicle_positions_service.dart';

/// #1017, second pass: what `fetchOnce(routeIds:)` sends and what it does
/// with OTP's answer, over a scripted [Link] instead of the HTTP client.
void main() {
  Map<String, dynamic> vehicle(String id) => {
    'vehicleId': id,
    'label': id,
    'lat': -12.0464,
    'lon': -77.0428,
    'heading': 90.0,
    'speed': 5.0,
    'lastUpdate': DateTime.now().toUtc().toIso8601String(),
    'lastUpdated': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'trip': {'gtfsId': '1:trip-$id'},
  };

  Map<String, dynamic> route(String gtfsId, List<Map<String, dynamic>> v) => {
    'gtfsId': gtfsId,
    'color': 'FF0000',
    'patterns': [
      {'code': '$gtfsId:0:01', 'vehiclePositions': v},
    ],
  };

  group('OtpVehiclePositionsProvider.fetchOnce with routeIds', () {
    test(
      'asks routes(ids:) and keeps the filtered answer off the stream',
      () async {
        final link = _ScriptedLink([
          {
            'routes': [
              route('1:1185', [vehicle('v1')]),
            ],
          },
        ]);
        final provider = OtpVehiclePositionsProvider(
          endpoint: 'http://otp',
          link: link,
        );
        final published = <List<Object?>>[];
        final sub = provider.positionsStream.listen(published.add);

        final got = await provider.fetchOnce(routeIds: {'1:1185'});
        await Future<void>.delayed(Duration.zero);

        expect(got.map((p) => p.vehicleId), ['v1']);
        expect(link.documents, hasLength(1));
        expect(link.documents.single, contains('routes(ids: ["1:1185"])'));
        expect(
          provider.latest,
          isEmpty,
          reason: 'a subset must not replace the fleet the map paints',
        );
        expect(published, isEmpty);
        await sub.cancel();
      },
    );

    test(
      'an id the server does not know comes back as null and is skipped',
      () async {
        final link = _ScriptedLink([
          {
            'routes': [
              route('1:1185', [vehicle('v1')]),
              null,
            ],
          },
        ]);
        final provider = OtpVehiclePositionsProvider(
          endpoint: 'http://otp',
          link: link,
        );

        final got = await provider.fetchOnce(routeIds: {'1:1185', '1:nope'});

        expect(got.map((p) => p.vehicleId), ['v1']);
      },
    );

    test(
      'a server that rejects routes(ids:) gets the fleet query, now and from then on',
      () async {
        final fleet = {
          'routes': [
            route('1:1185', [vehicle('v1')]),
            route('1:1481', [vehicle('v2')]),
          ],
        };
        final link = _ScriptedLink([
          [
            GraphQLError(
              message:
                  "Validation error (UnknownArgument@[routes]) : Unknown field argument 'ids'",
              extensions: const {'classification': 'ValidationError'},
            ),
          ],
          fleet,
          fleet,
        ]);
        final provider = OtpVehiclePositionsProvider(
          endpoint: 'http://otp',
          link: link,
        );

        final first = await provider.fetchOnce(routeIds: {'1:1185'});
        final second = await provider.fetchOnce(routeIds: {'1:1185'});

        expect(first, hasLength(2));
        expect(second, hasLength(2));
        expect(link.documents, hasLength(3));
        expect(link.documents[0], contains('routes(ids'));
        expect(link.documents[1], isNot(contains('routes(ids')));
        expect(
          link.documents[2],
          isNot(contains('routes(ids')),
          reason: 'latched',
        );
        expect(
          provider.latest,
          hasLength(2),
          reason: 'a fleet-wide answer is published',
        );
      },
    );

    test('an empty set is "no route at all": no request', () async {
      final link = _ScriptedLink(const []);
      final provider = OtpVehiclePositionsProvider(
        endpoint: 'http://otp',
        link: link,
      );

      expect(await provider.fetchOnce(routeIds: {}), isEmpty);
      expect(link.documents, isEmpty);
    });

    test(
      'a snapshot of the whole fleet is published like a poll tick',
      () async {
        final link = _ScriptedLink([
          {
            'routes': [
              route('1:1185', [vehicle('v1')]),
            ],
          },
        ]);
        final provider = OtpVehiclePositionsProvider(
          endpoint: 'http://otp',
          link: link,
        );
        final published = <List<Object?>>[];
        final sub = provider.positionsStream.listen(published.add);

        final got = await provider.fetchOnce();
        await Future<void>.delayed(Duration.zero);

        expect(got, hasLength(1));
        expect(provider.latest, hasLength(1));
        expect(published, hasLength(1));
        await sub.cancel();
      },
    );
  });
}

/// Answers each request with the next scripted entry: a data map, or a
/// list of [GraphQLError]s.
class _ScriptedLink extends Link {
  _ScriptedLink(List<Object> answers) : _answers = List.of(answers);

  final List<Object> _answers;
  final documents = <String>[];

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    documents.add(printNode(request.operation.document));
    if (_answers.isEmpty) throw StateError('no scripted answer left');
    final answer = _answers.removeAt(0);
    if (answer is List<GraphQLError>) {
      yield Response(response: const <String, dynamic>{}, errors: answer);
    } else {
      yield Response(
        response: const <String, dynamic>{},
        data: answer as Map<String, dynamic>,
      );
    }
  }
}
