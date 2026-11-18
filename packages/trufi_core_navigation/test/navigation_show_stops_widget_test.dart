import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/src/presentation/widgets/navigation_bottom_panel.dart';
import 'package:trufi_core_navigation/src/presentation/widgets/navigation_instruction_card.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';

/// #1059 (trufi-sanaa#18): what the rider reads on the instruction card
/// with and without the stops, and the switch reaching the card from
/// `NavigationScreen.showFromItinerary(config: …)`, the call an app makes.
void main() {
  final wayNode = find.textContaining('Way node');
  final stopCount = find.textContaining('remaining');
  final nextPreview = find.text('Next: ');

  Widget host(Widget body, {Locale locale = const Locale('en')}) => MaterialApp(
    locale: locale,
    localizationsDelegates: NavigationLocalizations.localizationsDelegates,
    supportedLocales: [locale],
    home: Scaffold(
      body: Align(alignment: Alignment.bottomCenter, child: body),
    ),
  );

  /// The state of a rider who started the Sana'a-like trip and is now at
  /// [fix].
  Future<NavigationState> stateAt(LatLng fix, {required bool showStops}) async {
    final gps = FakeLocationService();
    final cubit = NavigationCubit(
      locationService: gps,
      config: NavigationConfig(showStops: showStops),
    );
    await cubit.startNavigation(
      ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary()),
    );
    gps.moveTo(fix);
    final state = cubit.state;
    await cubit.close();
    return state;
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    LatLng fix, {
    required bool showStops,
    Locale locale = const Locale('en'),
  }) async {
    final state = await stateAt(fix, showStops: showStops);
    await tester.pumpWidget(
      host(
        NavigationBottomPanel(
          state: state,
          showStops: showStops,
          onExitNavigation: () {},
        ),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The flex of the passed / remaining halves of the progress bar.
  List<int> progressBar(WidgetTester tester) => [
    for (final half in tester.widgetList<Expanded>(
      find.descendant(
        of: find.byType(ClipRRect),
        matching: find.byType(Expanded),
      ),
    ))
      half.flex,
  ];

  group('the instruction card', () {
    testWidgets('showStops on (default): the next way node, the count, the '
        'distance to it and the preview (unchanged)', (tester) async {
      await pumpPanel(tester, SanaaTrip.node(9), showStops: true);

      // Once as the instruction, once in the "Next: …" row.
      expect(find.text('Way node 11'), findsNWidgets(2));
      expect(find.text('36 stops remaining'), findsOneWidget);
      expect(nextPreview, findsOneWidget);
      expect(find.text('54 m'), findsOneWidget);
      expect(find.text('~26 min'), findsOneWidget);
    });

    testWidgets('showStops off: the alighting stop and the distance to it; '
        'no way node, no count, no distance to the next node, no preview', (
      tester,
    ) async {
      await pumpPanel(tester, SanaaTrip.node(9), showStops: false);

      expect(find.text('Alighting stop'), findsOneWidget);
      expect(find.text('991 m'), findsOneWidget);
      expect(wayNode, findsNothing);
      expect(stopCount, findsNothing);
      expect(nextPreview, findsNothing);
      expect(find.text('54 m'), findsNothing);
      // The ETA stays, and so does the line the rider is on.
      expect(find.text('~26 min'), findsOneWidget);
      expect(find.text('7'), findsWidgets);
    });

    testWidgets('showStops off holds on the card itself, whatever it is '
        'handed', (tester) async {
      // A state built with the stops: it carries a preview and a distance
      // to the next node, which the card has to leave out by itself.
      final state = await stateAt(SanaaTrip.node(9), showStops: true);
      expect(state.nextInstruction, isNotNull);
      expect(state.distanceToNextStop, isNotNull);

      await tester.pumpWidget(
        host(
          NavigationInstructionCard(
            instruction: state.currentInstruction!,
            nextInstruction: state.nextInstruction,
            remainingStops: state.remainingStops,
            totalStops: state.totalStops,
            currentStopIndex: state.currentStopIndex,
            distanceToNextStop: state.distanceToNextStop,
            etaToDestination: state.etaToDestination,
            legs: state.route!.legs,
            currentLeg: state.currentLeg,
            totalDuration: state.etaToDestination,
            showStops: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(nextPreview, findsNothing);
      expect(find.text('54 m'), findsNothing);
      expect(find.text('~26 min'), findsOneWidget);
    });

    testWidgets('the progress bar is the same either way', (tester) async {
      await pumpPanel(tester, SanaaTrip.node(30), showStops: true);
      final withStops = progressBar(tester);

      await pumpPanel(tester, SanaaTrip.node(30), showStops: false);
      final withoutStops = progressBar(tester);

      // Stop 32 of 48: 68 % ridden, 32 % ahead.
      expect(withStops, [68, 32]);
      expect(withoutStops, withStops);
    });

    testWidgets('the distance is written in the language of the app', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        SanaaTrip.boarding,
        showStops: false,
        locale: const Locale('es'),
      );

      expect(find.text('Alighting stop'), findsOneWidget);
      expect(find.text('1,2 km'), findsOneWidget);
      expect(find.textContaining('paradas'), findsNothing);
    });

    testWidgets('its number follows the locale of the context, like the '
        'other distances of the card', (tester) async {
      // Mexican Spanish: the texts come from the `es` localizations, whose
      // decimal separator is a comma, but the country writes a point.
      await pumpPanel(
        tester,
        SanaaTrip.boarding,
        showStops: false,
        locale: const Locale('es', 'MX'),
      );

      expect(find.text('Salir de la navegación'), findsOneWidget);
      expect(find.text('1.2 km'), findsOneWidget);
      expect(find.text('1,2 km'), findsNothing);
    });
  });

  group('NavigationScreen.showFromItinerary', () {
    // The screen keeps the display awake through a platform plugin.
    final realWakelock = wakelockPlusPlatformInstance;
    setUp(() => wakelockPlusPlatformInstance = _NoWakelock());
    tearDown(() => wakelockPlusPlatformInstance = realWakelock);

    /// Opens the navigation of the Sana'a-like trip the way an app does.
    Future<FakeLocationService> startNavigation(
      WidgetTester tester, {
      NavigationConfig? config,
    }) async {
      final gps = FakeLocationService();
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                if (config == null) {
                  NavigationScreen.showFromItinerary(
                    context,
                    itinerary: SanaaTrip.itinerary(),
                    locationService: gps,
                    mapEngineManager: FakeMapEngineManager(),
                  );
                } else {
                  NavigationScreen.showFromItinerary(
                    context,
                    itinerary: SanaaTrip.itinerary(),
                    locationService: gps,
                    mapEngineManager: FakeMapEngineManager(),
                    config: config,
                  );
                }
              },
              child: const Text('Start'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationScreen), findsOneWidget);
      return gps;
    }

    Future<void> moveTo(
      WidgetTester tester,
      FakeLocationService gps,
      LatLng fix,
    ) async {
      gps.moveTo(fix);
      await tester.pumpAndSettle();
    }

    testWidgets('NavigationConfig(showStops: false): the whole trip without '
        'a way node, a count or a preview', (tester) async {
      final gps = await startNavigation(
        tester,
        config: const NavigationConfig(showStops: false),
      );

      // Before the first fix: the walk to the line.
      expect(find.text('Boarding stop'), findsOneWidget);
      expect(find.text('150 m'), findsOneWidget);

      final seen = <String>{};
      for (final fix in SanaaTrip.track) {
        await moveTo(tester, gps, fix);
        expect(wayNode, findsNothing, reason: 'at $fix');
        expect(stopCount, findsNothing, reason: 'at $fix');
        expect(nextPreview, findsNothing, reason: 'at $fix');
        for (final name in ['Boarding stop', 'Alighting stop', 'University']) {
          if (find.text(name).evaluate().isNotEmpty) seen.add(name);
        }

        if (fix == SanaaTrip.boarding) {
          expect(find.text('Alighting stop'), findsOneWidget);
          expect(find.text('1.2 km'), findsOneWidget);
          expect(find.text('~33 min'), findsOneWidget);
          // 54 m to the next way node: not on the card.
          expect(find.text('54 m'), findsNothing);
        }
      }

      expect(seen, {'Boarding stop', 'Alighting stop', 'University'});
      expect(find.text('You have arrived!'), findsOneWidget);
      expect(find.text('University'), findsOneWidget);
    });

    testWidgets('the default config keeps naming and counting the stops '
        '(unchanged)', (tester) async {
      final gps = await startNavigation(tester);

      expect(find.text('47 stops remaining'), findsOneWidget);

      await moveTo(tester, gps, SanaaTrip.boarding);
      expect(find.text('Way node 2'), findsNWidgets(2));
      expect(find.text('45 stops remaining'), findsOneWidget);
      expect(nextPreview, findsOneWidget);
      expect(find.text('54 m'), findsOneWidget);
      expect(find.text('~33 min'), findsOneWidget);
      expect(find.text('Alighting stop'), findsNothing);
    });
  });
}

/// A wakelock that does nothing. `wakelock_plus` only exports its platform
/// interface through the desktop implementations, hence the base class.
class _NoWakelock extends WakelockPlusMacOSPlugin {
  @override
  Future<void> toggle({required bool enable}) async {}

  @override
  Future<bool> get enabled async => false;
}
