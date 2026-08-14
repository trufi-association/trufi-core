import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// End-to-end over a real OTP 1.5 response (Cochabamba GTFS, south →
/// north-west transfer search, captured 2026-08-12 from a local OTP 1.5
/// instance and trimmed to 5 itineraries):
///
/// 0. `123 → 106`   ┐
/// 1. `123 → 106`   ├ same main bus, interchangeable connections (#737)
/// 2. `123 → 120`   ┘
/// 3. `18 → 120`    ┐ different main buses left alone after the main pass,
/// 4. `8 → 120`     ┘ sharing the SAME final 120 — the mirror rule merges
///                    them ("tienen en común el 120")
void main() {
  late Plan plan;

  setUpAll(() {
    final raw =
        File('test/fixtures/otp_1_5_transfer_plan.json').readAsStringSync();
    plan = Otp15ResponseParser.parsePlan(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('real OTP 1.5 transfer plan collapses 5 rows into 2 groups', () {
    final itineraries = plan.itineraries!;
    expect(itineraries, hasLength(5));

    final groups = groupItineraries(itineraries);

    expect(groups, hasLength(2));

    final merged = groups.first;
    expect(merged.representative, same(itineraries[0]));
    expect(merged.alternatives, hasLength(3));
    expect(merged.hasRouteAlternatives, isTrue);
    expect(
      merged.slotRoutes[0].map((r) => r.shortName),
      ['123'],
      reason: 'shared main bus renders as a single chip',
    );
    expect(
      merged.slotRoutes[1].map((r) => r.shortName),
      ['106', '120'],
      reason: 'interchangeable connections render as segments',
    );

    // 18→120 and 8→120 share the same final 120: one mirror group whose
    // options are the main buses.
    final mirror = groups[1];
    expect(mirror.alternatives, hasLength(2));
    expect(mirror.slotRoutes[0].map((r) => r.shortName), ['18', '8']);
    expect(mirror.slotRoutes[1].map((r) => r.shortName), ['120']);
  });
}
