import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showTrufiModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const SizedBox(
                    height: 200,
                    child: Text('Sheet content'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the sheet content', (tester) async {
    await openSheet(tester);
    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets(
    'wraps both barrier and sheet content in PointerInterceptor '
    'so platform views (maps) cannot receive pointer events on web',
    (tester) async {
      await openSheet(tester);

      expect(find.byType(PointerInterceptor), findsNWidgets(2));
      // One interceptor must cover the modal barrier
      expect(
        find.ancestor(
          of: find.byType(ModalBarrier),
          matching: find.byType(PointerInterceptor),
        ),
        findsOneWidget,
      );
      // And one must cover the sheet content
      expect(
        find.ancestor(
          of: find.text('Sheet content'),
          matching: find.byType(PointerInterceptor),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping the barrier dismisses the sheet', (tester) async {
    await openSheet(tester);
    await tester.tapAt(const Offset(400, 50));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsNothing);
  });

  testWidgets('returns the value popped from the sheet', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showTrufiModalBottomSheet<String>(
                    context: context,
                    builder: (sheetContext) => SizedBox(
                      height: 200,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('picked'),
                        child: const Text('Pick'),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    expect(result, 'picked');
  });
}
