import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// `TrufiPlannerConfig.directsHideTransfers` reaches the planner through
/// the provider (trufi-sanaa#16): with it off, a trip served by one direct
/// line also lists the one-transfer options, after the direct one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const asset = 'assets/routing/sanaa_issue2_mini.gtfs.zip';
  late Uint8List zip;

  // A pair of the planner's own regression fixture with one direct line
  // (19961501) and four one-transfer options (see
  // trufi_core_planner/test/directs_hide_transfers_test.dart).
  const from = RoutingLocation(
    position: LatLng(15.346045, 44.220847),
    description: 'from',
  );
  const to = RoutingLocation(
    position: LatLng(15.353365, 44.174865),
    description: 'to',
  );

  setUpAll(() {
    final file = File(
      '../trufi_core_planner/test/fixtures/sanaa_issue2_mini.gtfs.zip',
    );
    expect(file.existsSync(), isTrue, reason: 'run from the package root');
    zip = file.readAsBytesSync();
  });

  setUp(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          return key == asset ? ByteData.sublistView(zip) : null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  Future<List<Itinerary>> planWith({required bool directsHideTransfers}) async {
    final provider = TrufiPlannerProvider(
      config: TrufiPlannerConfig.local(
        gtfsAsset: asset,
        maxWalkingDistance: 1500,
        directsHideTransfers: directsHideTransfers,
        persistIndex: false,
      ),
    );
    await provider.initialize();
    expect(provider.isLoaded, isTrue, reason: provider.errorMessage);
    final plan = await provider.fetchPlan(
      from: from,
      to: to,
      dateTime: DateTime(2026, 10, 27, 8),
    );
    return plan.itineraries!
        .where((i) => i.legs.any((l) => l.transitLeg))
        .toList();
  }

  test('default: the direct line alone', () async {
    final transit = await planWith(directsHideTransfers: true);
    expect(transit, hasLength(1));
    expect(transit.single.transfers, 0);
    expect(
      transit.single.legs.where((l) => l.transitLeg).single.route?.gtfsId,
      '19961501',
    );
  });

  test(
    'off: the same direct line first, then the one-transfer options',
    () async {
      final transit = await planWith(directsHideTransfers: false);
      expect(transit, hasLength(5));
      expect(transit.first.transfers, 0);
      expect(
        transit.first.legs.where((l) => l.transitLeg).single.route?.gtfsId,
        '19961501',
      );
      expect(transit.skip(1).map((i) => i.transfers), everyElement(1));
      expect(
        transit
            .skip(1)
            .map(
              (i) => i.legs
                  .where((l) => l.transitLeg)
                  .map((l) => l.route?.gtfsId)
                  .join('>'),
            ),
        [
          '18800489>19961501',
          '20080675>19961501',
          '19961501>18800916',
          '18800658>19961501',
        ],
      );
    },
  );
}
