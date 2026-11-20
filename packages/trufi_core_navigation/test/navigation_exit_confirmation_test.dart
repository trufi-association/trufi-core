import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // No code path pauses today (the background only lowers the GPS rate,
    // setBackgroundMode); pauseNavigation is public API, so it stays held.
    testWidgets('also while paused', (tester) async {
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

    testWidgets('once the screen closed, a link goes without asking', (
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

    // The app keeps its LeaveConfirmations for its whole life: a question
    // left in it would hold the closed screen, one more per navigation.
    testWidgets('the screen removes its question when it closes', (
      tester,
    ) async {
      final confirmations = _CountingConfirmations();
      await startNavigation(
        tester,
        _CountingLocationService(),
        confirmations: confirmations,
      );
      expect(confirmations.questions, 1);

      await tester.tap(find.text('Exit Navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(navigation, findsNothing);
      expect(confirmations.questions, 0);
    });
  });

  // An app's screens live in a nested navigator (go_router's ShellRoute in
  // TrufiApp), the navigation with them. On Android (predictive back, an app
  // targeting SDK 36) the framework tells the system whether it handles the
  // next back; when it says no, the system closes the app.
  group('in a nested navigator, as under the app shell', () {
    late List<bool> handlesBack;

    setUp(() {
      handlesBack = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
              handlesBack.add(call.arguments as bool);
            }
            return null;
          });
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    Future<void> startNested(
      WidgetTester tester, {
      LeaveConfirmations? confirmations,
    }) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final app = MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: NavigationLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => NavigationScreen.showFromItinerary(
                  context,
                  itinerary: SanaaTrip.itinerary(),
                  locationService: _CountingLocationService(),
                  mapEngineManager: FakeMapEngineManager(),
                ),
                child: const Text('Start'),
              ),
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
      await tester.pumpAndSettle();
      expect(navigation, findsOneWidget);
      expect(handlesBack.last, isTrue);
    }

    testWidgets('after Cancel the app still handles the next back', (
      tester,
    ) async {
      await startNested(tester);

      await tester.tap(find.text('Exit Navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(navigation, findsOneWidget);
      expect(handlesBack.last, isTrue);
    });

    testWidgets("also after Cancel on a link's question", (tester) async {
      final confirmations = LeaveConfirmations();
      await startNested(tester, confirmations: confirmations);

      final answer = confirmations.confirm();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await answer, isFalse);
      expect(handlesBack.last, isTrue);
    });
  });

  testWidgets("a link's question closes the app's menu open over the "
      'navigation, which would cover it', (tester) async {
    // Like the app shell: a menu over a nested navigator that holds the
    // navigation.
    final shell = GlobalKey<ScaffoldState>();
    final confirmations = LeaveConfirmations();
    await tester.pumpWidget(
      RepositoryProvider<LeaveConfirmations>.value(
        value: confirmations,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates:
              NavigationLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            key: shell,
            drawer: const Drawer(child: Text('menu')),
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) => TextButton(
                  onPressed: () => NavigationScreen.showFromItinerary(
                    context,
                    itinerary: SanaaTrip.itinerary(),
                    locationService: _CountingLocationService(),
                    mapEngineManager: FakeMapEngineManager(),
                  ),
                  child: const Text('Start'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    shell.currentState!.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('menu'), findsOneWidget);

    final answer = confirmations.confirm();
    await tester.pumpAndSettle();

    expect(shell.currentState!.isDrawerOpen, isFalse);
    expect(find.text('menu'), findsNothing);
    // On top, where the rider can answer it.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);
    expect(navigation, findsOneWidget);
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

/// A [LeaveConfirmations] that counts the questions it holds.
class _CountingConfirmations extends LeaveConfirmations {
  int questions = 0;

  @override
  void add(Future<bool> Function() question) {
    questions++;
    super.add(question);
  }

  @override
  void remove(Future<bool> Function() question) {
    questions--;
    super.remove(question);
  }
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
