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

Future<AppRouter> _pump(WidgetTester tester) async {
  _visits.clear();
  final appRouter = AppRouter(
    screens: [
      _Screen(
        '/',
        'Home',
        body: (context) => Center(
          child: TextButton(
            onPressed: () => context.push('/nearby', extra: 'a street'),
            child: const Text('open for a street'),
          ),
        ),
      ),
      _Screen('/nearby', 'Nearby lines'),
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

/// The drawer item of the section on screen does nothing, unless the
/// section was opened for a context (an `extra`): then it opens the plain
/// section in its place (trufi-core#1054, Nearby lines along a street).
void main() {
  testWidgets('over a visit opened with an extra, the section\'s own item '
      'opens the plain section in its place', (tester) async {
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

  testWidgets('on the plain section its own item still does nothing', (
    tester,
  ) async {
    await _pump(tester);
    await _tapDrawerItem(tester, 'Nearby lines');
    expect(_visits, ['plain']);

    await _tapDrawerItem(tester, 'Nearby lines');
    expect(find.text('plain'), findsOneWidget);
    expect(_visits, ['plain']);
  });
}
