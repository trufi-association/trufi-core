import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_ui/src/l10n/core_localizations.dart';
import 'package:trufi_core_ui/src/router/app_router.dart';

/// Every visit of the fake section: what its screen was opened for.
final _visits = <String>[];

class _Screen extends TrufiScreen {
  _Screen(this.path, this.title, {this.body});

  @override
  final String path;
  final String title;
  final Widget Function(BuildContext context)? body;

  @override
  String get id => title;
  @override
  bool get hasOwnAppBar => true;
  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(icon: Icons.circle);
  @override
  List<LocalizationsDelegate> get localizationsDelegates => const [];
  @override
  String getLocalizedTitle(BuildContext context) => title;
  @override
  Widget Function(BuildContext context) get builder =>
      body ?? (context) => _Section(extra: GoRouterState.of(context).extra);
}

/// Like Nearby lines: a visit opened with an `extra` is about that context
/// (a street from the search), a plain one about the section itself.
class _Section extends StatefulWidget {
  const _Section({this.extra});
  final Object? extra;
  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  @override
  void initState() {
    super.initState();
    _visits.add(widget.extra == null ? 'plain' : 'for ${widget.extra}');
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Text(widget.extra == null ? 'plain' : 'for ${widget.extra}'),
  );
}

/// Like the home screen's search: a page-less route over Home, from which
/// a street opens Nearby lines.
class _Search extends StatelessWidget {
  const _Search();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => context.push('/nearby', extra: 'a street'),
        child: const Text('lines along a street'),
      ),
    ),
  );
}

Future<AppRouter> _pump(WidgetTester tester, {String? initialRoute}) async {
  _visits.clear();
  final appRouter = AppRouter(
    initialRoute: initialRoute,
    screens: [
      _Screen(
        '/',
        'Home',
        body: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => context.push('/nearby', extra: 'a street'),
                child: const Text('open for a street'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _Search()),
                ),
                child: const Text('open the search'),
              ),
            ],
          ),
        ),
      ),
      _Screen('/nearby', 'Nearby lines'),
      _Screen('/routes', 'Routes'),
    ],
  );
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => SharedRouteNotifier(),
      child: MaterialApp.router(
        supportedLocales: CoreLocalizations.supportedLocales,
        localizationsDelegates: CoreLocalizations.localizationsDelegates,
        routerConfig: appRouter.router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return appRouter;
}

Future<void> _tapDrawerItem(WidgetTester tester, String title) async {
  // The edge swipe: a visit pushed over another screen shows back, not menu.
  await tester.dragFrom(const Offset(4, 300), const Offset(300, 0));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(Drawer), matching: find.text(title)),
  );
  await tester.pumpAndSettle();
}

/// How many Home screens are mounted, the covered ones too.
int _homes() =>
    find.text('open for a street', skipOffstage: false).evaluate().length;

/// Home is the only screen left: on screen, alone, and Back has nothing
/// to pop back to.
void _expectHomeAlone(AppRouter appRouter) {
  expect(_homes(), 1);
  expect(find.text('open for a street'), findsOneWidget);
  expect(find.text('plain', skipOffstage: false), findsNothing);
  expect(find.text('for a street', skipOffstage: false), findsNothing);
  expect(find.text('lines along a street', skipOffstage: false), findsNothing);
  expect(appRouter.router.canPop(), isFalse);
  expect(appRouter.router.routeInformationProvider.value.uri.path, '/');
}

void main() {
  /// The drawer item of the section on screen does nothing, unless the
  /// section was opened for a context (an `extra`): then it opens the plain
  /// section in its place (trufi-core#1054, Nearby lines along a street).
  group('a section\'s own item', () {
    testWidgets('over a visit opened with an extra, opens the plain section '
        'in its place', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('open for a street'));
      await tester.pumpAndSettle();
      expect(find.text('for a street'), findsOneWidget);

      await _tapDrawerItem(tester, 'Nearby lines');
      expect(find.text('plain'), findsOneWidget);
      expect(find.text('for a street'), findsNothing);
      expect(_visits, ['for a street', 'plain']);

      // In its place: back goes home, not to the street.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('open for a street'), findsOneWidget);
    });

    testWidgets('on the plain section still does nothing', (tester) async {
      await _pump(tester);
      await _tapDrawerItem(tester, 'Nearby lines');
      expect(_visits, ['plain']);

      await _tapDrawerItem(tester, 'Nearby lines');
      expect(find.text('plain'), findsOneWidget);
      expect(_visits, ['plain']);
    });
  });

  /// Home is the bottom of the stack: its item goes back to it instead of
  /// stacking a second one (two maps, two planner listeners, and a Back
  /// that lands on the other Home).
  group('the Home item', () {
    testWidgets('from a section goes back to the Home under it', (
      tester,
    ) async {
      final appRouter = await _pump(tester);
      await _tapDrawerItem(tester, 'Nearby lines');
      await _tapDrawerItem(tester, 'Routes');
      expect(_homes(), 1);

      await _tapDrawerItem(tester, 'Home');
      _expectHomeAlone(appRouter);
    });

    testWidgets('over a street visit opened from the search closes the '
        'search too', (tester) async {
      final appRouter = await _pump(tester);
      await tester.tap(find.text('open the search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('lines along a street'));
      await tester.pumpAndSettle();
      expect(find.text('for a street'), findsOneWidget);

      await _tapDrawerItem(tester, 'Home');
      _expectHomeAlone(appRouter);
    });

    testWidgets('over one of Home\'s own screens does nothing: it does not '
        'close them (a navigation in progress has its own confirmation)', (
      tester,
    ) async {
      final appRouter = await _pump(tester);
      await tester.tap(find.text('open the search'));
      await tester.pumpAndSettle();

      await _tapDrawerItem(tester, 'Home');
      expect(find.text('lines along a street'), findsOneWidget);
      expect(_homes(), 1);
      expect(appRouter.router.routeInformationProvider.value.uri.path, '/');

      // Its own back still returns to Home.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      _expectHomeAlone(appRouter);
    });

    testWidgets('deep-linked into a section, opens Home in its place', (
      tester,
    ) async {
      final appRouter = await _pump(tester, initialRoute: '/nearby');
      expect(find.text('plain'), findsOneWidget);
      expect(_homes(), 0);

      await _tapDrawerItem(tester, 'Home');
      _expectHomeAlone(appRouter);
    });

    testWidgets('on Home does nothing, also when Home was opened with an '
        'extra', (tester) async {
      final appRouter = await _pump(tester);
      await _tapDrawerItem(tester, 'Home');
      _expectHomeAlone(appRouter);

      appRouter.router.go('/', extra: 'a context');
      await tester.pumpAndSettle();
      await _tapDrawerItem(tester, 'Home');
      _expectHomeAlone(appRouter);
    });
  });
}
