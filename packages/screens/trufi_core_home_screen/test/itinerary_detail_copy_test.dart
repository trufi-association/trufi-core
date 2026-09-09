import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// trufi-sanaa#9 on the itinerary timeline: long-press on the origin,
/// transfer/destination and intermediate-stop names copies them. These rows
/// had no gesture at all before.
List<String> mockClipboard() {
  final copied = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      copied.add((call.arguments as Map)['text'] as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return copied;
}

routing.Place place(String name) =>
    routing.Place(name: name, lat: -17.39, lon: -66.15);

void main() {
  final bus = routing.Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 9, 9, 8),
    endTime: DateTime(2026, 9, 9, 8, 30),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:123', shortName: '123'),
    shortName: '123',
    fromPlace: place('Plaza Colón'),
    toPlace: place('Terminal de Buses'),
    // Bab al-Yemen station, Sana'a, as the second stop.
    intermediatePlaces: [place('Parada Ayacucho'), place('محطة باب اليمن')],
  );

  final itinerary = routing.Itinerary(
    legs: [bus],
    startTime: DateTime(2026, 9, 9, 8),
    endTime: DateTime(2026, 9, 9, 8, 30),
    walkTime: Duration.zero,
    duration: const Duration(minutes: 30),
    walkDistance: 0,
  );

  Widget host({TextDirection? textDirection}) =>
      Provider<AppConfiguration?>.value(
        value: AppConfiguration(appName: 'Test', screens: const []),
        child: MaterialApp(
          localizationsDelegates:
              HomeScreenLocalizations.localizationsDelegates,
          supportedLocales: HomeScreenLocalizations.supportedLocales,
          builder: textDirection == null
              ? null
              : (context, child) =>
                    Directionality(textDirection: textDirection, child: child!),
          home: Scaffold(body: ItineraryDetailContent(itinerary: itinerary)),
        ),
      );

  Future<void> expandStops(WidgetTester tester) async {
    await tester.tap(find.text('2 stops'));
    await tester.pumpAndSettle();
  }

  testWidgets('long-press on the origin and the destination copies them', (
    tester,
  ) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Plaza Colón'));
    await tester.pump();
    expect(copied, ['Plaza Colón']);
    expect(find.text('Copied'), findsOneWidget);

    await tester.longPress(find.text('Terminal de Buses'));
    await tester.pump();
    expect(copied, ['Plaza Colón', 'Terminal de Buses']);
  });

  testWidgets('intermediate stops copy once expanded; the expand toggle '
      'still works', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Parada Ayacucho'), findsNothing);
    await expandStops(tester);
    expect(find.text('Parada Ayacucho'), findsOneWidget);

    await tester.longPress(find.text('Parada Ayacucho'));
    await tester.pump();
    expect(copied, ['Parada Ayacucho']);

    // Collapsing again is untouched by the new gesture.
    await tester.tap(find.text('2 stops'));
    await tester.pumpAndSettle();
    expect(find.text('Parada Ayacucho'), findsNothing);
  });

  testWidgets('RTL: an Arabic stop name is copied whole', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host(textDirection: TextDirection.rtl));
    await tester.pumpAndSettle();
    await expandStops(tester);

    final stop = find.text('محطة باب اليمن');
    expect(Directionality.of(tester.element(stop)), TextDirection.rtl);
    await tester.longPress(stop);
    await tester.pump();

    expect(copied, ['محطة باب اليمن']);
  });
}
