import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_ui/src/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.resolveInAppLocation', () {
    test('custom scheme maps host to the first path segment (issue #924)', () {
      expect(
        DeepLinkService.resolveInAppLocation(
          Uri.parse('trufiapp://routes?operator=Trufi%20Express'),
        ),
        '/routes?operator=Trufi%20Express',
      );
    });

    test('custom scheme with sub-path keeps it', () {
      expect(
        DeepLinkService.resolveInAppLocation(Uri.parse('trufiapp://routes/42')),
        '/routes/42',
      );
    });

    test('https links use the path as-is', () {
      expect(
        DeepLinkService.resolveInAppLocation(
          Uri.parse('https://app.example.com/routes?operator=Micros'),
        ),
        '/routes?operator=Micros',
      );
    });

    test('bare domains and roots resolve to null', () {
      expect(
        DeepLinkService.resolveInAppLocation(
          Uri.parse('https://app.example.com'),
        ),
        isNull,
      );
      expect(
        DeepLinkService.resolveInAppLocation(
          Uri.parse('https://app.example.com/'),
        ),
        isNull,
      );
    });

    test('query is dropped cleanly when absent', () {
      expect(
        DeepLinkService.resolveInAppLocation(Uri.parse('trufiapp://routes')),
        '/routes',
      );
    });
  });
}
