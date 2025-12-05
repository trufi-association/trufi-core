import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/services/search_location_service.dart';

/// Unit tests for SearchLocationException.
void main() {
  group('SearchLocationException', () {
    test('creates instance with message only', () {
      final exception = SearchLocationException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates instance with message and status code', () {
      final exception = SearchLocationException(
        'HTTP error',
        statusCode: 404,
      );

      expect(exception.message, 'HTTP error');
      expect(exception.statusCode, 404);
      expect(exception.originalError, isNull);
    });

    test('creates instance with all parameters', () {
      final originalError = FormatException('Invalid format');
      final exception = SearchLocationException(
        'Parse error',
        statusCode: 500,
        originalError: originalError,
      );

      expect(exception.message, 'Parse error');
      expect(exception.statusCode, 500);
      expect(exception.originalError, originalError);
    });

    test('toString returns formatted message', () {
      final exception = SearchLocationException('Test error message');

      expect(
        exception.toString(),
        'SearchLocationException: Test error message',
      );
    });

    test('implements Exception interface', () {
      final exception = SearchLocationException('Test');

      expect(exception, isA<Exception>());
    });
  });
}
