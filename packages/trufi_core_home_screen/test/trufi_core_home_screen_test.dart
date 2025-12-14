import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

void main() {
  group('RoutePlannerState', () {
    test('initial state has correct defaults', () {
      const state = RoutePlannerState();

      expect(state.fromPlace, isNull);
      expect(state.toPlace, isNull);
      expect(state.plan, isNull);
      expect(state.selectedItinerary, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('isPlacesDefined returns false when no places', () {
      const state = RoutePlannerState();
      expect(state.isPlacesDefined, isFalse);
    });

    test('hasError returns true when error is set', () {
      const state = RoutePlannerState(error: 'Test error');
      expect(state.hasError, isTrue);
    });

    test('copyWith preserves values not being changed', () {
      const state = RoutePlannerState(
        isLoading: true,
        error: 'Test error',
      );

      final newState = state.copyWith(isLoading: false);

      expect(newState.isLoading, isFalse);
      expect(newState.error, equals('Test error'));
    });

    test('copyWithNullable can set values to null', () {
      const state = RoutePlannerState(error: 'Test error');

      final newState = state.copyWithNullable(
        error: const Optional(null),
      );

      expect(newState.error, isNull);
    });
  });

  group('HomeScreenConfig', () {
    test('has correct defaults', () {
      const config = HomeScreenConfig(otpEndpoint: 'https://example.com');

      expect(config.chooseLocationZoom, equals(16.0));
      expect(config.myPlaces, isEmpty);
    });

    test('can set custom values', () {
      const config = HomeScreenConfig(
        otpEndpoint: 'https://example.com',
        chooseLocationZoom: 18.0,
        photonUrl: 'https://custom.photon.url/api/',
      );

      expect(config.chooseLocationZoom, equals(18.0));
      expect(config.photonUrl, equals('https://custom.photon.url/api/'));
    });
  });
}
