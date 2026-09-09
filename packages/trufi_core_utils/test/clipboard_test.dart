import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// Captures every `Clipboard.setData` payload sent over the platform channel
/// (the same seam Flutter's own clipboard tests use). When [fail] is set the
/// write is rejected, as Safari does outside a user gesture.
List<String> mockClipboard({bool fail = false}) {
  final copied = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      if (fail) throw PlatformException(code: 'NotAllowedError');
      copied.add((call.arguments as Map)['text'] as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return copied;
}

void main() {
  late BuildContext hostContext;

  Widget host() => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          hostContext = context;
          return const SizedBox.expand();
        },
      ),
    ),
  );

  testWidgets('writes the text to the clipboard synchronously and confirms', (
    tester,
  ) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host());

    final call = copyToClipboard(
      hostContext,
      'Plaza Colón',
      confirmation: 'Copied',
    );
    // Before any frame or microtask: the write already left for the
    // platform (Safari only honours writes made inside the gesture).
    expect(copied, ['Plaza Colón']);

    await call;
    await tester.pump();
    expect(find.text('Copied'), findsOneWidget);

    // Short-lived: the dismiss timer starts once the entrance animation
    // ends; after the duration the exit animation runs and it is gone.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(copyConfirmationDuration);
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('a second copy replaces the previous confirmation instead of '
      'queueing behind it', (tester) async {
    mockClipboard();
    await tester.pumpWidget(host());

    await copyToClipboard(hostContext, 'a', confirmation: 'Copied a');
    await tester.pump();
    await copyToClipboard(hostContext, 'b', confirmation: 'Copied b');
    await tester.pump();
    // Let the first one's exit animation run.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Copied a'), findsNothing);
    expect(find.text('Copied b'), findsOneWidget);
  });

  testWidgets('a rejected write shows no confirmation', (tester) async {
    final copied = mockClipboard(fail: true);
    await tester.pumpWidget(host());

    await copyToClipboard(hostContext, 'x', confirmation: 'Copied');
    await tester.pump();

    expect(copied, isEmpty);
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('without a ScaffoldMessenger it still copies and does not '
      'throw', (tester) async {
    final copied = mockClipboard();
    late BuildContext bareContext;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            bareContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    await copyToClipboard(bareContext, 'x', confirmation: 'Copied');
    await tester.pump();

    expect(copied, ['x']);
    expect(tester.takeException(), isNull);
  });
}
