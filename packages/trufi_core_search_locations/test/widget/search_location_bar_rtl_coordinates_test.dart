import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// #1024: under a right-to-left UI the Home field painted a coordinate pair
/// as "44.22437 ,15.29483". The field renders [SearchLocation.formattedDisplay],
/// which now carries a left-to-right mark in front of the pair; this test
/// measures where the two numbers land on screen instead of looking for the
/// mark in the string.
const _pair = SearchLocation(
  id: 'coordinates:15.29483,44.22437',
  displayName: '15.29483, 44.22437',
  address: 'صنعاء',
  latitude: 15.29483,
  longitude: 44.22437,
);

Widget _rtlBar(SearchLocationState state) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: SearchLocationsLocalizations.localizationsDelegates,
  supportedLocales: SearchLocationsLocalizations.supportedLocales,
  builder: (context, child) =>
      Directionality(textDirection: TextDirection.rtl, child: child!),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 800,
        child: SearchLocationBar(
          state: state,
          showMenuButton: false,
          onSearch: ({required bool isOrigin}) async => null,
          onOriginSelected: (_) {},
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  ),
);

/// Left edge, on screen, of [part] inside the paragraph that contains it.
double _leftOf(WidgetTester tester, String containing, String part) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains(containing),
    ),
  );
  final text = paragraph.text.toPlainText();
  final start = text.indexOf(part);
  expect(start, greaterThanOrEqualTo(0), reason: '"$part" in "$text"');
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: start, extentOffset: start + part.length),
  );
  expect(boxes, isNotEmpty);
  return paragraph.localToGlobal(Offset(boxes.first.left, 0)).dx;
}

void main() {
  testWidgets('RTL bar: the latitude is painted left of the longitude', (
    tester,
  ) async {
    await tester.pumpWidget(_rtlBar(const SearchLocationState(origin: _pair)));
    await tester.pump();

    final lat = _leftOf(tester, '15.29483', '15.29483');
    final lon = _leftOf(tester, '15.29483', '44.22437');
    expect(
      lat,
      lessThan(lon),
      reason: 'with the mark the pair keeps its written order under RTL',
    );
  });

  testWidgets('control: the bare pair in an RTL paragraph comes out reversed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Text('15.29483, 44.22437, صنعاء')),
      ),
    );

    final lat = _leftOf(tester, '15.29483', '15.29483');
    final lon = _leftOf(tester, '15.29483', '44.22437');
    expect(
      lat,
      greaterThan(lon),
      reason: 'this is the bug: the bidi algorithm swaps the two numbers',
    );
  });
}
