import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_maps_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TrufiMapsExampleApp());
    expect(find.text('Trufi Core Maps'), findsOneWidget);
  });
}
