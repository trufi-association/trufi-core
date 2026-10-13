import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #1005: transit badges wear the GTFS route colour; anything that is not six
// hex digits falls back instead of painting a transparent or wrong colour.

void main() {
  const fallback = Colors.red;

  group('SavedRouteCard.badgeColor', () {
    test('parses six hex digits, with or without a leading #', () {
      expect(
        SavedRouteCard.badgeColor('7E57C2', fallback),
        const Color(0xFF7E57C2),
      );
      expect(
        SavedRouteCard.badgeColor('#7e57c2', fallback),
        const Color(0xFF7E57C2),
      );
    });

    test('falls back for null, empty and malformed values', () {
      expect(SavedRouteCard.badgeColor(null, fallback), fallback);
      expect(SavedRouteCard.badgeColor('', fallback), fallback);
      expect(SavedRouteCard.badgeColor('FFF', fallback), fallback);
      expect(SavedRouteCard.badgeColor('zzzzzz', fallback), fallback);
      expect(SavedRouteCard.badgeColor('#', fallback), fallback);
    });
  });
}
