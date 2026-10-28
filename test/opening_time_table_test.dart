import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/transit_service_hours/opening_time_table.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/simple_opening_hours.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/transport_frecuency.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

// 2026-10-26 is a Monday.
DateTime at(int hour, [int minute = 0]) => DateTime(2026, 10, 26, hour, minute);

Widget app(Widget child, {Locale locale = const Locale('es')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
      supportedLocales: TrufiBaseLocalization.supportedLocales,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

Future<void> expand(WidgetTester tester) async {
  await tester.tap(find.byType(ExpansionTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a single departure is listed as a departure, not as closed',
      (tester) async {
    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: SimpleOpeningHours('Mo-Su 17:30'),
      now: at(10),
    )));
    expect(find.text('Salidas: 17:30'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
    expect(find.text('Servicio activo'), findsNothing);
    expect(find.text('¡Actualmente fuera de servicio!'), findsNothing);
    expect(find.textContaining('null'), findsNothing);

    await expand(tester);
    // header + the seven weekdays; public holidays stay "Cerrado"
    expect(find.text('Salidas: 17:30'), findsNWidgets(8));
    expect(find.text('Cerrado'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('after the last departure of the day the header says so',
      (tester) async {
    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: SimpleOpeningHours('Mo-Su 17:30'),
      now: at(18),
    )));
    expect(find.text('Sin más salidas hoy'), findsOneWidget);
    expect(find.text('Servicio activo'), findsNothing);
    expect(find.text('¡Actualmente fuera de servicio!'), findsNothing);
    // the same red badge as "out of service": the itinerary leg shows its
    // red marker in this state (isOpenNow is false)
    final badge = tester.widget<Container>(find
        .ancestor(
          of: find.text('Sin más salidas hoy'),
          matching: find.byType(Container),
        )
        .first);
    expect((badge.decoration as BoxDecoration).color, const Color(0xFFD72A2A));
    expect(find.byIcon(Icons.schedule), findsNothing);
    expect(SimpleOpeningHours('Mo-Su 17:30').isOpenOn(at(18)), isFalse);
  });

  testWidgets('only the departures still ahead are in the header',
      (tester) async {
    // written out of order on purpose: the parser sorts them
    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: SimpleOpeningHours('Mo-Su 07:10,05:00'),
      now: at(6),
    )));
    expect(find.text('Salidas: 07:10'), findsOneWidget);
    await expand(tester);
    expect(find.text('Salidas: 05:00, 07:10'), findsNWidgets(7));
  });

  testWidgets('a short service window keeps the active / out-of-service badge',
      (tester) async {
    final openingHours = SimpleOpeningHours('Mo-Su 04:00-05:45');
    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: openingHours,
      now: at(5),
    )));
    expect(find.text('Servicio activo'), findsOneWidget);
    expect(find.text('cierra a las 05:45'), findsOneWidget);

    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: openingHours,
      now: at(10),
    )));
    expect(find.text('¡Actualmente fuera de servicio!'), findsOneWidget);
    expect(find.textContaining('Salidas'), findsNothing);
    await expand(tester);
    expect(find.text('04:00-05:45'), findsNWidgets(7));
  });

  testWidgets('a window and a departure on the same day', (tester) async {
    final openingHours = SimpleOpeningHours('Mo-Su 05:00-07:10,17:30');
    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: openingHours,
      now: at(6),
    )));
    expect(find.text('Servicio activo'), findsOneWidget);
    expect(find.text('cierra a las 07:10'), findsOneWidget);

    await tester.pumpWidget(app(OpeningTimeTable(
      openingHours: openingHours,
      now: at(12),
    )));
    expect(find.text('Salidas: 17:30'), findsOneWidget);
    await expand(tester);
    expect(find.text('05:00-07:10'), findsNWidgets(7));
    expect(find.text('Salidas: 17:30'), findsNWidgets(8));
  });

  testWidgets('the header is localized', (tester) async {
    await tester.pumpWidget(app(
      OpeningTimeTable(
        openingHours: SimpleOpeningHours('Mo-Su 17:30'),
        now: at(10),
      ),
      locale: const Locale('en'),
    ));
    expect(find.text('Departures: 17:30'), findsOneWidget);
    await expand(tester);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('every special Jilotepec line renders a schedule',
      (tester) async {
    for (final entry in transportFrecuency.entries) {
      // 03:00 precedes every special departure and window of the city.
      final openingHours = SimpleOpeningHours(entry.value);
      // A fresh key per line: the tile would otherwise keep the expanded
      // state of the previous iteration.
      await tester.pumpWidget(app(OpeningTimeTable(
        key: ValueKey(entry.key),
        openingHours: openingHours,
        now: at(3),
      )));
      expect(tester.takeException(), isNull, reason: entry.key);
      expect(find.textContaining('null'), findsNothing, reason: entry.key);
      final isWindow = openingHours.rangesOn(at(3)).isNotEmpty;
      expect(
        find.text('¡Actualmente fuera de servicio!'),
        isWindow ? findsOneWidget : findsNothing,
        reason: entry.key,
      );
      expect(
        find.textContaining('Salidas: '),
        isWindow ? findsNothing : findsOneWidget,
        reason: entry.key,
      );
      await expand(tester);
      expect(find.text('Cerrado'), findsOneWidget, reason: entry.key);
      expect(tester.takeException(), isNull, reason: entry.key);
    }
  });
}
