import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_ui/src/l10n/core_localizations.dart';
import 'package:trufi_core_ui/src/router/app_router.dart';

class _Screen extends TrufiScreen {
  _Screen(this.path, this.title, this.body);

  @override
  final String path;
  final String title;
  final Widget Function(BuildContext context) body;

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
  Widget Function(BuildContext context) get builder => body;
}

Future<void> _pump(WidgetTester tester) async {
  final appRouter = AppRouter(
    screens: [
      _Screen(
        '/',
        'Home',
        (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('home'),
              TextButton(
                onPressed: () => context.push('/routes'),
                child: const Text('open routes'),
              ),
              // Like the search or a navigation: a route pushed over Home,
              // with no page.
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const Scaffold(body: Center(child: Text('navigating'))),
                  ),
                ),
                child: const Text('start navigation'),
              ),
            ],
          ),
        ),
      ),
      _Screen(
        '/routes',
        'Routes',
        (context) => const Center(child: Text('routes')),
      ),
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
}

Future<void> _openDrawer(WidgetTester tester) async {
  // The edge swipe, which also opens it over a screen with no menu button.
  await tester.dragFrom(const Offset(4, 300), const Offset(300, 0));
  await tester.pumpAndSettle();
  expect(find.byType(Drawer), findsOneWidget);
}

/// The system back as the router gets it: Android's back button, or a back
/// gesture over a route without a predictive-back transition (a section's
/// page has one, and takes the gesture before the router).
Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// #1065: a back with the menu open closes the menu. go_router hands the back
/// to the shell's navigator, under the menu, so it closed the screen behind
/// the open menu instead (a navigation in progress with it).
void main() {
  testWidgets('over a screen pushed on Home without a page (a navigation), '
      'back closes the menu and leaves the screen', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('start navigation'));
    await tester.pumpAndSettle();
    await _openDrawer(tester);

    await _back(tester);

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('navigating'), findsOneWidget);

    // With the menu closed, back reaches the screen again.
    await _back(tester);
    expect(find.text('navigating'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('over a section, back closes the menu and leaves the section', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('open routes'));
    await tester.pumpAndSettle();
    await _openDrawer(tester);

    await _back(tester);

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('routes'), findsOneWidget);

    await _back(tester);
    expect(find.text('home'), findsOneWidget);
  });

  // Only when the back reaches the app. On Android with predictive back (an
  // app targeting SDK 36) the system keeps this one and leaves the app, the
  // same on main: nothing under the menu can pop, so Flutter tells the
  // system it does not handle back (flutter/flutter#145290 is that family).
  testWidgets('over Home alone, a back the app receives closes the menu '
      '(unchanged)', (tester) async {
    await _pump(tester);
    await _openDrawer(tester);

    await _back(tester);

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
