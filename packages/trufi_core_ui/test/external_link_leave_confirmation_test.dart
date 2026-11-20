import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core_ui/trufi_core_ui.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// #1065: an external link opened while the app runs replaces Home and every
/// screen over it. A screen the rider must not lose without being asked (a
/// navigation in progress) asks first, through the [LeaveConfirmations] that
/// `TrufiApp` provides; until then the link closed it at once.
void main() {
  const linkMethods = MethodChannel('com.llfbandit.app_links/messages');
  const linkEvents = EventChannel('com.llfbandit.app_links/events');
  late MockStreamHandlerEventSink links;

  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    _navigationsClosed = 0;
    SharedPreferences.setMockInitialValues({});
    // No link opened the app; the test sends the ones it receives running.
    messenger().setMockMethodCallHandler(linkMethods, (_) async => null);
    messenger().setMockStreamHandler(
      linkEvents,
      // A block body: what the callback returns goes back over the channel.
      MockStreamHandler.inline(
        onListen: (_, sink) {
          links = sink;
        },
      ),
    );
  });

  tearDown(() {
    messenger().setMockMethodCallHandler(linkMethods, null);
    messenger().setMockStreamHandler(linkEvents, null);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // `AppLinks` is a singleton that closes its stream once the app stops
    // listening, on the real event loop: close it before the next test
    // listens again.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    });
    await tester.pumpWidget(
      TrufiApp(
        config: AppConfiguration(
          appName: 'Test',
          deepLinkScheme: 'trufiapp',
          overlayManager: OverlayManager(),
          providers: [
            ChangeNotifierProvider<MapEngineManager>.value(value: _NoMaps()),
            ChangeNotifierProvider<RoutingEngineManager>.value(
              value: _NoRouting(),
            ),
          ],
          screens: [_Home(), _Routes()],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('start navigation'), findsOneWidget);
  }

  Future<void> receiveLink(WidgetTester tester, String link) async {
    links.success(link);
    // The platform message reaches the channel on the real event loop, which
    // the test's fake clock does not run.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> startNavigation(WidgetTester tester) async {
    await tester.tap(find.text('start navigation'));
    await tester.pumpAndSettle();
    expect(find.text('navigating'), findsOneWidget);
  }

  testWidgets('while a screen asks, No drops the link and keeps the screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await startNavigation(tester);

    await receiveLink(tester, 'trufiapp://routes?operator=Micro%20A');
    expect(find.text('Exit Navigation?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('navigating'), findsOneWidget);
    expect(find.textContaining('routes of'), findsNothing);
    expect(_navigationsClosed, 0);
  });

  testWidgets('Yes follows the link: the section replaces Home and the '
      'screen over it', (tester) async {
    await pumpApp(tester);
    await startNavigation(tester);

    await receiveLink(tester, 'trufiapp://routes?operator=Micro%20A');
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(find.text('routes of Micro A'), findsOneWidget);
    expect(find.text('navigating'), findsNothing);
    expect(_navigationsClosed, 1);
  });

  testWidgets('with no screen asking, the link goes at once (unchanged)', (
    tester,
  ) async {
    await pumpApp(tester);

    await receiveLink(tester, 'trufiapp://routes?operator=Micro%20A');

    expect(find.text('Exit Navigation?'), findsNothing);
    expect(find.text('routes of Micro A'), findsOneWidget);
  });

  testWidgets('once the screen closed, its question is gone with it', (
    tester,
  ) async {
    await pumpApp(tester);
    await startNavigation(tester);
    await tester.tap(find.text('end navigation'));
    await tester.pumpAndSettle();

    await receiveLink(tester, 'trufiapp://routes?operator=Micro%20A');

    expect(find.text('Exit Navigation?'), findsNothing);
    expect(find.text('routes of Micro A'), findsOneWidget);
  });

  testWidgets('a link to a screen the app does not have is still ignored, '
      'without asking', (tester) async {
    await pumpApp(tester);
    await startNavigation(tester);

    await receiveLink(tester, 'trufiapp://routes-hack');

    expect(find.text('Exit Navigation?'), findsNothing);
    expect(find.text('navigating'), findsOneWidget);
  });
}

/// How many times the stand-in navigation was closed (disposed).
var _navigationsClosed = 0;

class _Home extends TrufiScreen {
  @override
  String get id => 'home';
  @override
  String get path => '/';
  @override
  bool get hasOwnAppBar => true;
  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(icon: Icons.home);
  @override
  List<LocalizationsDelegate> get localizationsDelegates => const [];
  @override
  String getLocalizedTitle(BuildContext context) => 'Home';
  @override
  Widget Function(BuildContext context) get builder =>
      (context) => Center(
        child: TextButton(
          // Like NavigationScreen.show: a route pushed over Home, no page.
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const _Navigation())),
          child: const Text('start navigation'),
        ),
      );
}

class _Routes extends TrufiScreen {
  @override
  String get id => 'routes';
  @override
  String get path => '/routes';
  @override
  bool get hasOwnAppBar => true;
  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(icon: Icons.list);
  @override
  List<LocalizationsDelegate> get localizationsDelegates => const [];
  @override
  String getLocalizedTitle(BuildContext context) => 'Routes';
  @override
  Widget Function(BuildContext context) get builder =>
      (context) => Center(
        child: Text(
          'routes of ${GoRouterState.of(context).uri.queryParameters['operator']}',
        ),
      );
}

/// Stands in for `NavigationScreen` (`trufi_core_navigation` builds on this
/// package, not the other way round): while on screen it asks, through the
/// [LeaveConfirmations] above it, the exit question before a link replaces
/// it.
class _Navigation extends StatefulWidget {
  const _Navigation();

  @override
  State<_Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<_Navigation> {
  LeaveConfirmations? _confirmations;

  @override
  void initState() {
    super.initState();
    _confirmations = LeaveConfirmations.maybeOf(context)?..add(_ask);
  }

  @override
  void dispose() {
    _confirmations?.remove(_ask);
    _navigationsClosed++;
    super.dispose();
  }

  Future<bool> _ask() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Navigation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('navigating'),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('end navigation'),
          ),
        ],
      ),
    ),
  );
}

/// The managers `TrufiApp` initializes before showing the screens; nothing
/// else of them is used here.
class _NoMaps extends ChangeNotifier implements MapEngineManager {
  @override
  Future<void> initializeEngines() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRouting extends ChangeNotifier implements RoutingEngineManager {
  @override
  Future<void> initializeEngines() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
