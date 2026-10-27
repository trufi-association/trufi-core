import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// In-memory provider: the list is whatever it was built with.
class _FakeProvider extends TransportListDataProvider {
  _FakeProvider(List<TransportRoute> routes) {
    state = TransportListState(
      routes: routes,
      filteredRoutes: routes,
      isLoading: false,
    );
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async => null;
}

/// Enough routes to overflow the 600 px test surface several times over
/// (Sana'a ships ~200; trufi-sanaa#19).
List<TransportRoute> _routes(int count) => List.generate(
  count,
  (i) => TransportRoute(
    id: '$i',
    code: 'R$i',
    name: 'Linea $i',
    shortName: '$i',
    agencyName: i.isEven ? 'Trufi Express' : 'Micros Unidos',
  ),
);

Future<void> _pump(
  WidgetTester tester,
  List<TransportRoute> routes, {
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: TransportListLocalizations.localizationsDelegates,
      supportedLocales: TransportListLocalizations.supportedLocales,
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: TransportListContent(
            dataProvider: _FakeProvider(routes),
            onRouteTap: (_) {},
          ),
        ),
      ),
    ),
  );
  // Post-frame initial load + the staggered entrance animation.
  await tester.pumpAndSettle();
}

ScrollController _listController(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!;

/// Press at [start] and drag down by [dy], the way Flutter's own scrollbar
/// tests drive the thumb: the press has to settle before the move so the
/// thumb recognizer wins the arena.
Future<void> _dragDown(WidgetTester tester, Offset start, double dy) async {
  final gesture = await tester.startGesture(start);
  await tester.pumpAndSettle();
  await gesture.moveBy(Offset(0, dy));
  await tester.pumpAndSettle();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the routes list carries a persistent, draggable scrollbar '
      'on the same controller as the list', (tester) async {
    await _pump(tester, _routes(40));

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
    expect(scrollbar.interactive, isTrue);
    expect(scrollbar.controller, same(_listController(tester)));
    expect(_listController(tester).position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('LTR: dragging the thumb on the right edge scrolls the list '
      'farther than the drag itself', (tester) async {
    await _pump(tester, _routes(40));
    final list = tester.getRect(find.byType(ListView));
    final controller = _listController(tester);
    expect(controller.offset, 0);

    // The thumb hugs the right edge at the top; a 60 px thumb drag has to
    // move the content by a multiple of that (content / viewport ratio).
    await _dragDown(tester, Offset(list.right - 2, list.top + 20), 60);
    expect(controller.offset, greaterThan(120));

    // The left edge is plain content in LTR: dragging down there from the
    // top only overscrolls (pull-to-refresh), the offset does not grow.
    controller.jumpTo(0);
    await tester.pumpAndSettle();
    await _dragDown(tester, Offset(list.left + 2, list.top + 20), 60);
    expect(controller.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL (Arabic): the thumb moves to the left edge and stays '
      'draggable', (tester) async {
    await _pump(tester, _routes(40), textDirection: TextDirection.rtl);
    final list = tester.getRect(find.byType(ListView));
    final controller = _listController(tester);
    expect(controller.offset, 0);

    await _dragDown(tester, Offset(list.left + 2, list.top + 20), 60);
    expect(controller.offset, greaterThan(120));

    // And the right edge is content now.
    controller.jumpTo(0);
    await tester.pumpAndSettle();
    await _dragDown(tester, Offset(list.right - 2, list.top + 20), 60);
    expect(controller.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a short list has nothing to scroll and no thumb to grab', (
    tester,
  ) async {
    await _pump(tester, _routes(2));
    final list = tester.getRect(find.byType(ListView));
    final controller = _listController(tester);

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(controller.position.maxScrollExtent, 0);
    await _dragDown(tester, Offset(list.right - 2, list.top + 20), 60);
    expect(controller.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop (web with a mouse): only the explicit scrollbar is in the '
    'tree, so the thumb is not painted twice',
    (tester) async {
      await _pump(tester, _routes(40));

      // MaterialScrollBehavior wraps every vertical scrollable in a Scrollbar
      // of its own on linux/macOS/windows; the list opts out of that one and
      // keeps the explicit, draggable bar (#1020).
      expect(find.byType(Scrollbar), findsOneWidget);
      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar.thumbVisibility, isTrue);
      expect(scrollbar.controller, same(_listController(tester)));

      final list = tester.getRect(find.byType(ListView));
      await _dragDown(tester, Offset(list.right - 2, list.top + 20), 60);
      expect(_listController(tester).offset, greaterThan(120));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.desktop(),
  );

  testWidgets(
    'Android: still one scrollbar, and opting out of the automatic bar keeps '
    'the rest of the platform behaviour (stretch overscroll)',
    (tester) async {
      await _pump(tester, _routes(40));

      expect(find.byType(Scrollbar), findsOneWidget);
      // The inherited behaviour is copied, not replaced: Android's stretch
      // overscroll still wraps the list.
      expect(
        find.descendant(
          of: find.byType(Scrollbar),
          matching: find.byType(StretchingOverscrollIndicator),
        ),
        findsOneWidget,
      );

      final list = tester.getRect(find.byType(ListView));
      await _dragDown(tester, Offset(list.right - 2, list.top + 20), 60);
      expect(_listController(tester).offset, greaterThan(120));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
