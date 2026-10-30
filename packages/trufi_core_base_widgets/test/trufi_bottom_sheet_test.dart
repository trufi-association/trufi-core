import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';

/// The sheet's grabber and its optional pinned header sit OUTSIDE the
/// `DraggableScrollableSheet`'s scrollable, which is the only thing that
/// resizes the sheet on its own — so the widget drives the controller by
/// hand for drags on them (#1055). Test surface: 800×600, no app bar, so
/// the sheet's parent is 600 px tall and 100 px of finger = 1/6 of size.
void main() {
  const snaps = [0.2, 0.5, 0.9];

  group('snapTargetFor', () {
    test('a plain release settles on the nearest snap', () {
      expect(TrufiBottomSheet.snapTargetFor(0.3, 0, snaps), 0.2);
      expect(TrufiBottomSheet.snapTargetFor(0.45, 0, snaps), 0.5);
      expect(TrufiBottomSheet.snapTargetFor(0.6, 0, snaps), 0.5);
      expect(TrufiBottomSheet.snapTargetFor(0.8, 0, snaps), 0.9);
      // Below kMinFlingVelocity (50 px/s) it is still a release.
      expect(TrufiBottomSheet.snapTargetFor(0.6, 49, snaps), 0.5);
      expect(TrufiBottomSheet.snapTargetFor(0.6, -49, snaps), 0.5);
    });

    test('a fling goes to the next snap in its direction', () {
      expect(TrufiBottomSheet.snapTargetFor(0.55, 300, snaps), 0.9);
      expect(TrufiBottomSheet.snapTargetFor(0.85, -300, snaps), 0.5);
    });

    test('outside the range or already on a snap: nothing to decide', () {
      expect(TrufiBottomSheet.snapTargetFor(0.1, 0, snaps), 0.2);
      expect(TrufiBottomSheet.snapTargetFor(0.95, 0, snaps), 0.9);
      expect(TrufiBottomSheet.snapTargetFor(0.5, 0, snaps), 0.5);
      expect(TrufiBottomSheet.snapTargetFor(0.5, 300, snaps), 0.5);
    });
  });

  Widget host({DraggableScrollableController? controller, bool header = true}) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TrufiBottomSheet(
              controller: controller,
              initialChildSize: 0.5,
              minChildSize: 0.2,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: const [0.2, 0.5],
              header: header
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Header'),
                    )
                  : null,
              child: Column(
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(height: 50, child: Text('Item $i')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('the header is pinned: scrolling the content leaves it in '
      'place', (tester) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller: controller));
    controller.jumpTo(0.9);
    await tester.pumpAndSettle();

    final headerTop = tester.getTopLeft(find.text('Header')).dy;
    final itemTop = tester.getTopLeft(find.text('Item 5')).dy;

    // At the max size a drag on the content scrolls it.
    await tester.drag(find.text('Item 5'), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(controller.size, closeTo(0.9, 0.001));
    expect(tester.getTopLeft(find.text('Header')).dy, headerTop);
    expect(tester.getTopLeft(find.text('Item 5')).dy, lessThan(itemTop - 150));
  });

  testWidgets('dragging the header resizes the sheet and a release snaps to '
      'the nearest size', (tester) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller: controller));
    await tester.pumpAndSettle();
    expect(controller.size, closeTo(0.5, 0.001));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Header')),
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    // The drag recognizer eats the touch slop before its first update.
    expect(controller.size, closeTo(0.5 + 100 / 600, 0.04));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.size, closeTo(0.5, 0.001));
  });

  testWidgets('a fling on the header goes to the next snap in its direction', (
    tester,
  ) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller: controller));
    await tester.pumpAndSettle();

    await tester.fling(find.text('Header'), const Offset(0, -80), 1500);
    await tester.pumpAndSettle();
    expect(controller.size, closeTo(0.9, 0.001));

    await tester.fling(find.text('Header'), const Offset(0, 80), 1500);
    await tester.pumpAndSettle();
    expect(controller.size, closeTo(0.5, 0.001));
  });

  testWidgets('the grabber above the header drags too', (tester) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller: controller));
    await tester.pumpAndSettle();

    // 10 px above the header text: the grabber's margin area.
    final gesture = await tester.startGesture(
      tester.getTopLeft(find.text('Header')) + const Offset(100, -10),
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(controller.size, greaterThan(0.6));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('without an external controller the handle still works', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.text('Header')).dy;

    await tester.fling(find.text('Header'), const Offset(0, -80), 1500);
    await tester.pumpAndSettle();

    // 0.5 → 0.9 of 600 px: the header moved up by ~240 px.
    expect(tester.getTopLeft(find.text('Header')).dy, closeTo(before - 240, 2));
  });

  testWidgets('no header: the sheet renders and the content still drags it', (
    tester,
  ) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller: controller, header: false));
    await tester.pumpAndSettle();
    expect(find.text('Header'), findsNothing);
    expect(find.text('Item 0'), findsOneWidget);

    await tester.fling(find.text('Item 2'), const Offset(0, -80), 1500);
    await tester.pumpAndSettle();
    expect(controller.size, closeTo(0.9, 0.001));
  });
}
