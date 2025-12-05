import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/models/search_location.dart';
import 'package:trufi_core_search_locations/src/models/search_location_state.dart';

import '../test_config.dart';

/// Unit tests for SearchLocationState model.
void main() {
  group('SearchLocationState', () {
    test('creates instance with null values by default', () {
      const state = SearchLocationState();

      expect(state.origin, isNull);
      expect(state.destination, isNull);
    });

    test('creates instance with origin and destination', () {
      const state = SearchLocationState(
        origin: TestConfig.berlinLocation,
        destination: TestConfig.brandenburgGateLocation,
      );

      expect(state.origin, TestConfig.berlinLocation);
      expect(state.destination, TestConfig.brandenburgGateLocation);
    });

    group('isComplete', () {
      test('returns true when both origin and destination are set', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state.isComplete, isTrue);
      });

      test('returns false when only origin is set', () {
        const state = SearchLocationState(origin: TestConfig.berlinLocation);

        expect(state.isComplete, isFalse);
      });

      test('returns false when only destination is set', () {
        const state = SearchLocationState(
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state.isComplete, isFalse);
      });

      test('returns false when both are null', () {
        const state = SearchLocationState();

        expect(state.isComplete, isFalse);
      });
    });

    group('hasAnyLocation', () {
      test('returns true when both locations are set', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state.hasAnyLocation, isTrue);
      });

      test('returns true when only origin is set', () {
        const state = SearchLocationState(origin: TestConfig.berlinLocation);

        expect(state.hasAnyLocation, isTrue);
      });

      test('returns true when only destination is set', () {
        const state = SearchLocationState(
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state.hasAnyLocation, isTrue);
      });

      test('returns false when both are null', () {
        const state = SearchLocationState();

        expect(state.hasAnyLocation, isFalse);
      });
    });

    group('copyWith', () {
      test('updates origin while keeping destination', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final newState = state.copyWith(origin: TestConfig.cochabambaLocation);

        expect(newState.origin, TestConfig.cochabambaLocation);
        expect(newState.destination, TestConfig.brandenburgGateLocation);
      });

      test('updates destination while keeping origin', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final newState = state.copyWith(
          destination: TestConfig.cochabambaLocation,
        );

        expect(newState.origin, TestConfig.berlinLocation);
        expect(newState.destination, TestConfig.cochabambaLocation);
      });

      test('clears origin when clearOrigin is true', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final newState = state.copyWith(clearOrigin: true);

        expect(newState.origin, isNull);
        expect(newState.destination, TestConfig.brandenburgGateLocation);
      });

      test('clears destination when clearDestination is true', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final newState = state.copyWith(clearDestination: true);

        expect(newState.origin, TestConfig.berlinLocation);
        expect(newState.destination, isNull);
      });

      test('clearOrigin takes precedence over new origin value', () {
        const state = SearchLocationState(origin: TestConfig.berlinLocation);

        final newState = state.copyWith(
          origin: TestConfig.cochabambaLocation,
          clearOrigin: true,
        );

        expect(newState.origin, isNull);
      });

      test('keeps existing values when no changes provided', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final newState = state.copyWith();

        expect(newState.origin, TestConfig.berlinLocation);
        expect(newState.destination, TestConfig.brandenburgGateLocation);
      });
    });

    group('swapped', () {
      test('swaps origin and destination', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        final swapped = state.swapped();

        expect(swapped.origin, TestConfig.brandenburgGateLocation);
        expect(swapped.destination, TestConfig.berlinLocation);
      });

      test('handles null origin', () {
        const state = SearchLocationState(
          destination: TestConfig.brandenburgGateLocation,
        );

        final swapped = state.swapped();

        expect(swapped.origin, TestConfig.brandenburgGateLocation);
        expect(swapped.destination, isNull);
      });

      test('handles null destination', () {
        const state = SearchLocationState(origin: TestConfig.berlinLocation);

        final swapped = state.swapped();

        expect(swapped.origin, isNull);
        expect(swapped.destination, TestConfig.berlinLocation);
      });

      test('handles both null', () {
        const state = SearchLocationState();

        final swapped = state.swapped();

        expect(swapped.origin, isNull);
        expect(swapped.destination, isNull);
      });
    });

    group('SearchLocationState.empty', () {
      test('creates state with null origin and destination', () {
        const state = SearchLocationState.empty();

        expect(state.origin, isNull);
        expect(state.destination, isNull);
      });
    });

    group('equality', () {
      test('two states with same locations are equal', () {
        const state1 = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        const state2 = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state1, equals(state2));
      });

      test('two states with different origins are not equal', () {
        const state1 = SearchLocationState(origin: TestConfig.berlinLocation);
        const state2 = SearchLocationState(
          origin: TestConfig.cochabambaLocation,
        );

        expect(state1, isNot(equals(state2)));
      });

      test('state is equal to itself', () {
        const state = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state, equals(state));
      });
    });

    group('hashCode', () {
      test('same states produce same hashCode', () {
        const state1 = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        const state2 = SearchLocationState(
          origin: TestConfig.berlinLocation,
          destination: TestConfig.brandenburgGateLocation,
        );

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    test('toString returns expected format', () {
      const state = SearchLocationState(
        origin: TestConfig.berlinLocation,
        destination: TestConfig.brandenburgGateLocation,
      );

      expect(
        state.toString(),
        'SearchLocationState(origin: ${TestConfig.berlinLocation}, '
        'destination: ${TestConfig.brandenburgGateLocation})',
      );
    });
  });
}
