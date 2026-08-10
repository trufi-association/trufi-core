import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_ui/src/l10n/core_localizations.dart';
import 'package:trufi_core_ui/src/router/app_router.dart';

/// An app configured with zero screens must land on the fallback home —
/// not 404 on '/'. The deep-link route is always registered, so the
/// fallback has to key on the screen-derived routes, and its text must be
/// localized (#945).
void main() {
  Widget appWithNoScreens(Locale locale, {AppRouter? appRouter}) {
    return ChangeNotifierProvider(
      create: (_) => SharedRouteNotifier(),
      child: MaterialApp.router(
        locale: locale,
        supportedLocales: CoreLocalizations.supportedLocales,
        localizationsDelegates: CoreLocalizations.localizationsDelegates,
        routerConfig: (appRouter ?? AppRouter(screens: const [])).router,
      ),
    );
  }

  testWidgets('zero screens lands on the fallback home, localized', (
    tester,
  ) async {
    await tester.pumpWidget(appWithNoScreens(const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('No hay pantallas registradas'), findsOneWidget);
    expect(find.text('Página no encontrada'), findsNothing);
  });

  testWidgets('the fallback home is English for English apps', (tester) async {
    await tester.pumpWidget(appWithNoScreens(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('No screens registered'), findsOneWidget);
  });

  testWidgets('the /route deep link still redirects onto the fallback home', (
    tester,
  ) async {
    final appRouter = AppRouter(screens: const []);
    await tester.pumpWidget(
      appWithNoScreens(const Locale('es'), appRouter: appRouter),
    );
    await tester.pumpAndSettle();

    appRouter.router.go('/route');
    await tester.pumpAndSettle();

    expect(find.text('No hay pantallas registradas'), findsOneWidget);
  });
}
