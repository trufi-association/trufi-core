import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:gql/language.dart' show printNode;
import 'package:graphql/client.dart';
import 'package:trufi_core_routing/src/services/vehicle_positions_service.dart';

/// trufi-lima#14: the vehicle card could not say where the bus goes. OTP has
/// `headsign` per pattern; the query asks for it and every vehicle of the
/// pattern carries it.
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
        'trip': {'gtfsId': '1:trip-$id', 'directionId': '0'},
      };

  Map<String, dynamic> pattern(String? headsign, List<String> ids) => {
        'code': '1:1481:0:01',
        if (headsign != null) 'headsign': headsign,
        'vehiclePositions': [for (final id in ids) vehicle(id)],
      };

  OtpVehiclePositionsProvider providerAnswering(_ScriptedLink link) =>
      OtpVehiclePositionsProvider(endpoint: 'http://otp', link: link);

  test('the query asks for the headsign of each pattern', () {
    final q = buildVehiclePositionsQuery();
    final patternBlock = q.substring(q.indexOf('patterns'));
    expect(
      patternBlock.indexOf('headsign'),
      lessThan(patternBlock.indexOf('vehiclePositions')),
      reason: 'headsign is a field of the pattern, next to code',
    );
    expect(
      buildVehiclePositionsQuery(routeIds: {'1:1481'}),
      contains('headsign'),
    );
  });

  test('every vehicle of a pattern gets that pattern\'s headsign', () async {
    final link = _ScriptedLink([
      {
        'routes': [
          {
            'gtfsId': '1:1481',
            'color': 'FF0000',
            'patterns': [
              pattern('MINKA', ['v1', 'v2']),
              pattern('JICAMARCA', ['v3']),
            ],
          },
        ],
      },
    ]);
    final provider = providerAnswering(link);

    final got = await provider.fetchOnce();

    expect({
      for (final v in got) v.vehicleId: v.headsign
    }, {
      'v1': 'MINKA',
      'v2': 'MINKA',
      'v3': 'JICAMARCA',
    });
  });

  test('a pattern without headsign leaves it null', () async {
    final link = _ScriptedLink([
      {
        'routes': [
          {
            'gtfsId': '1:1481',
            'color': 'FF0000',
            'patterns': [
              pattern(null, ['v1']),
              pattern('', ['v2']),
            ],
          },
        ],
      },
    ]);
    final got = await providerAnswering(link).fetchOnce();

    expect(got.firstWhere((v) => v.vehicleId == 'v1').headsign, isNull);
    expect(
      got.firstWhere((v) => v.vehicleId == 'v2').headsign,
      anyOf(isNull, isEmpty),
      reason: 'an empty headsign is never shown as a row',
    );
  });
}

class _ScriptedLink extends Link {
  _ScriptedLink(List<Object> answers) : _answers = List.of(answers);
  final List<Object> _answers;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    printNode(request.operation.document);
    yield Response(
      response: const <String, dynamic>{},
      data: _answers.removeAt(0) as Map<String, dynamic>,
    );
  }
}
