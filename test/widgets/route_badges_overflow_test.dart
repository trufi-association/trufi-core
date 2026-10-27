import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/tile_transport.dart';

// The Arequipa feed takes route_short_name from the OSM ref, which carries the
// operator's sub-brand: up to 32 characters (trufi-arequipa#27).
const longShortName = '3 de octubre: B - Zona Alta Cono N';

TransitRoute _route({required String shortName}) => TransitRoute(
      id: 'r1',
      name: 'r1',
      code: 'r1',
      route: TransitInfo(
        shortName: shortName,
        longName: 'Terminal Terrestre → Ciudad de Dios',
        color: '0061D0',
      ),
    );

Widget _app(Widget child, {double width = 320}) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

Text _textWidget(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text));

void main() {
  testWidgets(
      'a 32-character route code neither overflows the list tile nor hides '
      'the terminal', (tester) async {
    await tester.pumpWidget(
      _app(TileTransport(patternOtp: _route(shortName: longShortName), onTap: () {})),
    );

    // Before the fix the row overflowed by dozens of pixels (RenderFlex
    // "A RenderFlex overflowed by ... pixels on the right").
    expect(tester.takeException(), isNull);

    final code = _textWidget(tester, longShortName);
    expect(code.overflow, TextOverflow.ellipsis);
    expect(code.maxLines, 1);

    final terminal = find.text('Ciudad de Dios');
    expect(terminal, findsOneWidget);
    // The terminal keeps real room: the code takes at most 55 % of the row.
    final codeBox = tester.getRect(find.text(longShortName));
    final terminalBox = tester.getRect(terminal);
    expect(terminalBox.width, greaterThan(60));
    expect(codeBox.right, lessThanOrEqualTo(terminalBox.left));
  });

  testWidgets('a short code renders exactly as before', (tester) async {
    await tester.pumpWidget(
      _app(TileTransport(patternOtp: _route(shortName: 'C9'), onTap: () {})),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('C9'), findsOneWidget);
    expect(find.text('Ciudad de Dios'), findsOneWidget);
    // Short codes take their natural width, not 55 % of the row.
    expect(tester.getRect(find.text('C9')).width, lessThan(40));
  });

  testWidgets('the summary badge ends a long code with an ellipsis instead of '
      'cutting glyphs', (tester) async {
    await tester.pumpWidget(
      _app(
        IconTransport(
          bacgroundColor: Colors.blue,
          color: Colors.white,
          icon: const Icon(Icons.directions_bus, size: 16),
          text: longShortName,
          isEnd: false,
        ),
        width: 120,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(_textWidget(tester, longShortName).overflow, TextOverflow.ellipsis);
  });
}
