import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Unit tests for OTP version enum and factory.
void main() {
  group('OtpVersion', () {
    test('has all expected versions', () {
      expect(OtpVersion.values.length, equals(3));
      expect(OtpVersion.values, contains(OtpVersion.v1_5));
      expect(OtpVersion.values, contains(OtpVersion.v2_4));
      expect(OtpVersion.values, contains(OtpVersion.v2_8));
    });

    test('displayName returns correct names', () {
      expect(OtpVersion.v1_5.displayName, equals('OTP 1.5'));
      expect(OtpVersion.v2_4.displayName, equals('OTP 2.4'));
      expect(OtpVersion.v2_8.displayName, equals('OTP 2.8'));
    });

    test('schemaDescription returns correct descriptions', () {
      expect(
        OtpVersion.v1_5.schemaDescription,
        contains('REST API'),
      );
      expect(
        OtpVersion.v2_4.schemaDescription,
        contains('GraphQL'),
      );
      expect(
        OtpVersion.v2_8.schemaDescription,
        contains('emissions'),
      );
    });
  });

  group('OtpRepositoryFactory', () {
    test('creates Otp15PlanRepository for v1_5', () {
      final repository = OtpRepositoryFactory.create(
        endpoint: 'https://example.com',
        version: OtpVersion.v1_5,
      );

      expect(repository, isA<Otp15PlanRepository>());
    });

    test('creates Otp24PlanRepository for v2_4', () {
      final repository = OtpRepositoryFactory.create(
        endpoint: 'https://example.com/graphql',
        version: OtpVersion.v2_4,
      );

      expect(repository, isA<Otp24PlanRepository>());
    });

    test('creates Otp28PlanRepository for v2_8', () {
      final repository = OtpRepositoryFactory.create(
        endpoint: 'https://example.com/graphql',
        version: OtpVersion.v2_8,
      );

      expect(repository, isA<Otp28PlanRepository>());
    });

    test('creates repository with useSimpleQuery option', () {
      final repository = OtpRepositoryFactory.create(
        endpoint: 'https://example.com/graphql',
        version: OtpVersion.v2_4,
        useSimpleQuery: true,
      );

      expect(repository, isA<Otp24PlanRepository>());
    });
  });
}
