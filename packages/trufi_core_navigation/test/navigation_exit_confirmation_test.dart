import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';

/// #1065: a navigation in progress ends only with the rider's word. The exit
/// button asked already; a back (button or gesture) and an external link
/// ended it without asking.
void main() {
  final question = find.text('Exit Navigation?');
  final navigation = find.byType(NavigationScreen);

  // The screen keeps the display awake through a platform plugin; the fake
  // records what it is told, the derived signal that the navigation ended.
  final realWakelock = wakelockPlusPlatformInstance;
  late _RecordingWakelock wakelock;
  setUp(() => wakelockPlusPlatformInstance = wakelock = _RecordingWakelock());
  tearDown(() => wakelockPlusPlatformInstance = realWakelock);

  /// Opens the navigation of the Sana'a-like trip the way an app does, under
  /// a home screen, with [confirmations] provided above the app as
  /// `TrufiApp` does (`RepositoryProvider` is a `Provider`).
  Future<void> startNavigation(
    WidgetTester tester,
    LocationService gps, {
    LeaveConfirmations? confirmations,
    bool settle = true,
  }) async {
    final app = MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: NavigationLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => NavigationScreen.showFromItinerary(
              context,
              itinerary: SanaaTrip.itinerary(),
              locationService: gps,
              mapEngineManager: FakeMapEngineManager(),
            ),
            child: const Text('Start'),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      confirmations == null
          ? app
          : RepositoryProvider<LeaveConfirmations>.value(
              value: confirmations,
              child: app,
            ),
    );
    await tester.tap(find.text('Start'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(navigation, findsOneWidget);
  }

  /// The system back: what Android's back button or back gesture sends.
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  group('a back while the navigation runs', () {
    testWidgets('asks the exit question; Cancel keeps the navigation', (
      tester,
    ) async {
      final gps = _CountingLocationService();
      await startNavigation(tester, gps);
      expect(find.text('47 stops remaining'), findsOneWidget);

      await systemBack(tester);
      expect(question, findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(question, findsNothing);
      expect(navigation, findsOneWidget);
      expect(find.text('47 stops remaining'), findsOneWidget);
      expect(gps.stops, 0);
      expect(wakelock.toggles, [true]);
    });

    testWidgets('Exit ends it, as the exit button does', (tester) async {
      final gps = _CountingLocationService();
      await startNavigation(tester, gps);

      await systemBack(tester);
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(navigation, findsNothing);
      expect(find.text('Start'), findsOneWidget);
      expect(gps.stops, greaterThan(0));
      expect(wakelock.toggles, [true, false]);
    });

    testWidgets('a second back closes the question, not the navigation', (
      tester,
    ) async {
      await startNavigation(tester, _CountingLocationService());

      await systemBack(tester);
      expect(question, findsOneWidget);
      await systemBack(tester);

      expect(question, findsNothing);
      expect(navigation, findsOneWidget);
      expect(wakelock.toggles, [true]);
    });

    testWidgets('also while paused (the app went to the background)', (
      tester,
    ) async {
      await startNavigation(tester, _CountingLocationService());
      // The cubit is provided under the screen: read it from the panel.
      tester
          .element(find.text('Exit Navigation'))
          .read<NavigationCubit>()
          .pauseNavigation();
      await tester.pumpAndSettle();

      await systemBack(tester);

      expect(question, findsOneWidget);
    });

    testWidgets('the exit button asks as before', (tester) async {
      await startNavigation(tester, _CountingLocationService());

      await tester.tap(find.text('Exit Navigation'));
      await tester.pumpAndSettle();
      expect(question, findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(navigation, findsOneWidget);

      await tester.tap(find.text('Exit Navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(navigation, findsNothing);
      expect(wakelock.toggles, [true, false]);
    });
  });

  group('with nothing to lose, a back closes without asking', () {
    testWidgets('before the first location', (tester) async {
      final gps = _CountingLocationService(permission: Completer());
      await startNavigation(tester, gps, settle: false);
      expect(find.text('Starting navigation...'), findsOneWidget);

      await systemBack(tester);

      expect(question, findsNothing);
      expect(navigation, findsNothing);
      // The permission arriving late has no screen left to start.
      gps.permission!.complete(LocationPermissionStatus.granted);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('after arrival', (tester) async {
      final gps = _CountingLocationService();
      await startNavigation(tester, gps);
      for (final fix in SanaaTrip.track) {
        gps.moveTo(fix);
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text('You have arrived!'), findsOneWidget);

      await systemBack(tester);

      expect(question, findsNothing);
      expect(navigation, findsNothing);
    });

    testWidgets('on the error panel', (tester) async {
      final gps = _CountingLocationService(
        denied: LocationPermissionStatus.denied,
      );
      await startNavigation(tester, gps);
      expect(find.text('Retry'), findsOneWidget);

      await systemBack(tester);

      expect(question, findsNothing);
      expect(navigation, findsNothing);
    });
  });

  group('the question an external link asks first (LeaveConfirmations)', () {
    testWidgets('while the navigation runs it is the exit question: Cancel '
        'drops the link and keeps the navigation', (tester) async {
      final confirmations = LeaveConfirmations();
      final gps = _CountingLocationService();
      await startNavigation(tester, gps, confirmations: confirmations);

      final answer = confirmations.confirm();
      await tester.pumpAndSettle();
      expect(question, findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await answer, isFalse);
      expect(navigation, findsOneWidget);
      expect(gps.stops, 0);
      expect(wakelock.toggles, [true]);
    });

    testWidgets('Exit lets the link go; the link, not the question, closes '
        'the screen', (tester) async {
      final confirmations = LeaveConfirmations();
      await startNavigation(
        tester,
        _CountingLocationService(),
        confirmations: confirmations,
      );

      final answer = confirmations.confirm();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(await answer, isTrue);
      expect(navigation, findsOneWidget);
    });

    testWidgets('before the first location it lets the link go without '
        'asking', (tester) async {
      final confirmations = LeaveConfirmations();
      final gps = _CountingLocationService(permission: Completer());
      await startNavigation(
        tester,
        gps,
        confirmations: confirmations,
        settle: false,
      );

      final answer = confirmations.confirm();
      await tester.pump();

      expect(question, findsNothing);
      expect(await answer, isTrue);
      gps.permission!.complete(LocationPermissionStatus.granted);
      await tester.pumpAndSettle();
    });

    testWidgets('the screen takes its question with it when it closes', (
      tester,
    ) async {
      final confirmations = LeaveConfirmations();
      await startNavigation(
        tester,
        _CountingLocationService(),
        confirmations: confirmations,
      );
      await tester.tap(find.text('Exit Navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(navigation, findsNothing);

      final answer = confirmations.confirm();
      await tester.pump();

      expect(question, findsNothing);
      expect(await answer, isTrue);
    });
  });
}

/// A [FakeLocationService] that counts the stops of the tracking and can
/// hold the permission ([permission], completed by the test) or deny it
/// ([denied]).
class _CountingLocationService extends FakeLocationService {
  _CountingLocationService({this.permission, this.denied});

  final Completer<LocationPermissionStatus>? permission;
  final LocationPermissionStatus? denied;
  int stops = 0;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      denied ?? await (permission?.future ?? super.requestPermission());

  @override
  Future<void> stopTracking() async => stops++;
}

/// A wakelock that records what it is told. `wakelock_plus` only exports
/// its platform interface through the desktop implementations, hence the
/// base class.
class _RecordingWakelock extends WakelockPlusMacOSPlugin {
  final toggles = <bool>[];

  @override
  Future<void> toggle({required bool enable}) async => toggles.add(enable);

  @override
  Future<bool> get enabled async => toggles.isNotEmpty && toggles.last;
}
