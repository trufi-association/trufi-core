import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// End-to-end over a real OTP 1.5 response (Cochabamba GTFS, south →
/// north-west transfer search, captured 2026-08-12 from a local OTP 1.5
/// instance and trimmed to 5 itineraries):
///
/// 0. `123 → 106`   ┐
/// 1. `123 → 106`   ├ identical first leg, interchangeable second (#737)
/// 2. `123 → 120`   ┘
/// 3. `18 → 120`    ┐ same second leg, but boarding points ~304 m apart —
/// 4. `8 → 120`     ┘ genuinely different journeys, must stay separate
void main() {
  late Plan plan;

  setUpAll(() {
    final raw =
        File('test/fixtures/otp_1_5_transfer_plan.json').readAsStringSync();
    plan = Otp15ResponseParser.parsePlan(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('real OTP 1.5 transfer plan collapses 5 rows into 3 groups', () {
    final itineraries = plan.itineraries!;
    expect(itineraries, hasLength(5));

    final groups = groupItineraries(itineraries);

    expect(groups, hasLength(3));

    final merged = groups.first;
    expect(merged.representative, same(itineraries[0]));
    expect(merged.alternatives, hasLength(3));
    expect(merged.hasRouteAlternatives, isTrue);
    expect(
      merged.slotRoutes[0].map((r) => r.shortName),
      ['123'],
      reason: 'shared first leg renders as a single chip',
    );
    expect(
      merged.slotRoutes[1].map((r) => r.shortName),
      ['106', '120'],
      reason: 'interchangeable second legs join as "106 / 120"',
    );

    // The mirrored case boards a block apart: two singleton groups.
    expect(groups[1].alternatives, hasLength(1));
    expect(groups[2].alternatives, hasLength(1));
    expect(groups[1].signature, isNot(groups[2].signature));
  });
}
