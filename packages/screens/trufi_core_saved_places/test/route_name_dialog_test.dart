import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #1005: the name sheet is shared by "save route" (home screen) and
// "rename route" (this package). It returns the trimmed name or null, and
// never lets an empty name through.

void main() {
  // The dialog's result; assigned when the host button opens it.
  late Future<String?> result;

  Widget host() => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            result = RouteNameDialog.show(
              context,
              title: 'Save route',
              initialName: 'Casa → Trabajo',
              fieldLabel: 'Route name',
              cancelLabel: 'Cancel',
              confirmLabel: 'Save',
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder confirmButton() => find.widgetWithText(FilledButton, 'Save');

  testWidgets('opens pre-filled and confirms the default name', (tester) async {
    await openDialog(tester);

    expect(
      find.widgetWithText(TextFormField, 'Casa → Trabajo'),
      findsOneWidget,
    );
    expect(find.text('Save route'), findsOneWidget);

    await tester.tap(confirmButton());
    await tester.pumpAndSettle();

    expect(await result, 'Casa → Trabajo');
    expect(find.byType(RouteNameDialog), findsNothing);
  });

  testWidgets('returns the typed name trimmed', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), '  Trabajo ');
    await tester.tap(confirmButton());
    await tester.pumpAndSettle();

    expect(await result, 'Trabajo');
  });

  testWidgets('an empty name disables confirm', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pump();

    expect(tester.widget<FilledButton>(confirmButton()).onPressed, isNull);
  });

  testWidgets('is a bottom sheet in the edit-place anatomy, not a dialog', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byIcon(Icons.label_outline), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).autofocus, isTrue);
  });

  testWidgets('the close button resolves to null', (tester) async {
    await openDialog(tester);

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
    expect(find.byType(RouteNameDialog), findsNothing);
  });

  testWidgets('dismissing the sheet resolves to null', (tester) async {
    await openDialog(tester);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(await result, isNull);
  });
}
