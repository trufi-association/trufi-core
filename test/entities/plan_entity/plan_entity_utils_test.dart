import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

void main() {
  group('getDistance', () {
    test('distances over 1000 meters should get formatted to german (,)', () {
      final local = MockTrufiLocalization();

      when(local.localeName).thenReturn('de');

      getDistance(local, 1503.342);

      verify(local.instructionDistanceKm("1,5"));
    });

    test('distances over 1000 meters should get formatted to english (.)', () {
      final local = MockTrufiLocalization();

      when(local.localeName).thenReturn('en');

      getDistance(local, 1503.342);

      verify(local.instructionDistanceKm("1.5"));
    });
  });
}

class MockTrufiLocalization extends Mock implements TrufiLocalization {}
