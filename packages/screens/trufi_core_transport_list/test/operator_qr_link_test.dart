import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/src/transport_list_trufi_screen.dart';

/// A QR is read by a camera, which resolves http(s) and nothing else — a
/// base that can't produce such a link must yield no code at all rather
/// than one that opens nothing (#953).
void main() {
  group('operatorQrLink (#953)', () {
    test('https base builds the operator link', () {
      expect(
        operatorQrLink('https://planner.trufi.app', 'Uspa Uspa'),
        'https://planner.trufi.app/routes?operator=Uspa+Uspa',
      );
    });

    test('http base is accepted too', () {
      expect(operatorQrLink('http://example.org', 'X'), startsWith('http://'));
    });

    test('a custom scheme yields no link', () {
      expect(operatorQrLink('trufiapp://app', 'Uspa Uspa'), isNull);
    });

    test('a base without a scheme yields no link', () {
      expect(operatorQrLink('planner.trufi.app', 'Uspa Uspa'), isNull);
    });

    test('null base yields no link', () {
      expect(operatorQrLink(null, 'Uspa Uspa'), isNull);
    });

    test('the port of the base is preserved', () {
      expect(
        operatorQrLink('http://localhost:8080', 'X'),
        'http://localhost:8080/routes?operator=X',
      );
    });
  });
}
