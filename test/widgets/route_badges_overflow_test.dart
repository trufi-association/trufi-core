import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/route_number.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/pages/transport_list/widgets/tile_transport.dart';

// The Arequipa feed takes route_short_name from the OSM ref, which carries the
// operator's sub-brand: this is its longest value, 32 characters
// (trufi-arequipa#27).
const longShortName = '4 de octubre: Terminal Terrestre';

TransitRoute _route({
  required String shortName,
  String longName = 'Terminal Terrestre → Ciudad de Dios',
}) =>
    TransitRoute(
      id: 'r1',
      name: 'r1',
      code: 'r1',
      route: TransitInfo(
        shortName: shortName,
        longName: longName,
        color: '0061D0',
      ),
    );

Widget _app(Widget child, {double width = 320, bool material3 = false}) =>
    MaterialApp(
      theme: ThemeData(useMaterial3: material3),
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
      _app(TileTransport(
          patternOtp: _route(shortName: longShortName), onTap: () {})),
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

  testWidgets(
      'a code the terminal leaves room for keeps its natural width '
      '(a flat 55 % cap cut it)', (tester) async {
    // A 12-character code next to a 5-character terminal: in the test font
    // (1 em per glyph) the code needs 144 px, more than 55 % of the row,
    // while the terminal needs only 80 px.
    const code = 'TrabajoA1234';
    await tester.pumpWidget(
      _app(
        TileTransport(
          patternOtp: _route(shortName: code, longName: 'Río Seco → Enace'),
          onTap: () {},
        ),
        width: 360,
      ),
    );
    expect(tester.takeException(), isNull);
    final row = tester.getRect(
      find.ancestor(of: find.text(code), matching: find.byType(Row)).first,
    );
    final paragraph = tester.renderObject<RenderParagraph>(find.text(code));
    expect(paragraph.didExceedMaxLines, isFalse, reason: 'not cut');
    expect(
      paragraph.size.width,
      greaterThan(row.width * 0.55),
      reason: 'the fixture must need more than the old 55 % cap',
    );
    expect(find.text('Enace'), findsOneWidget);
  });

  testWidgets(
      'under Material 3 the terminal is measured with the rendered '
      'style and is not cut', (tester) async {
    // Material 3 adds letterSpacing to bodyMedium: measuring the terminal
    // with the raw style under-estimated it by a few pixels and the last
    // glyph was cut when the code took all of codeMax.
    await tester.pumpWidget(
      _app(
        TileTransport(
            patternOtp:
                _route(shortName: longShortName, longName: 'Río Seco → Enace'),
            onTap: () {}),
        width: 411,
        material3: true,
      ),
    );
    expect(tester.takeException(), isNull);
    final terminal = tester.renderObject<RenderParagraph>(find.text('Enace'));
    expect(terminal.didExceedMaxLines, isFalse);
  });

  testWidgets('the itinerary details badge stays inside a narrow row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Row(
          children: [
            SizedBox(width: 60),
            Expanded(
              child: RouteNumber(
                transportMode: TransportMode.bus,
                backgroundColor: Colors.blue,
                text: longShortName,
                distance: '1,0 km',
                duration: '10 min',
              ),
            ),
          ],
        ),
        width: 220,
      ),
    );
    // Before: a 180 px cap inside a min-size Row ignored the row's width and
    // overflowed by dozens of pixels below 393 dp.
    expect(tester.takeException(), isNull);
    expect(_textWidget(tester, longShortName).overflow, TextOverflow.ellipsis);
    final row = tester.getRect(find.byType(Row).first);
    expect(
      tester.getRect(find.text(longShortName)).right,
      lessThanOrEqualTo(row.right),
    );
  });

  testWidgets(
      'the summary badge ends a long code with an ellipsis instead of '
      'cutting glyphs', (tester) async {
    await tester.pumpWidget(
      _app(
        const IconTransport(
          bacgroundColor: Colors.blue,
          color: Colors.white,
          icon: Icon(Icons.directions_bus, size: 16),
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
