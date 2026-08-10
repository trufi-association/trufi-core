import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_ui/src/app_initializer/default_init_screen.dart';
import 'package:trufi_core_ui/src/l10n/core_localizations.dart';

/// DefaultInitScreen renders before app initialization completes, so it can
/// be mounted without the CoreLocalizations delegate. Its fallback must
/// follow the ambient locale instead of always speaking English (#945).
void main() {
  Widget appWithoutCoreDelegate(Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: [locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DefaultInitScreen(onRetry: () {}),
    );
  }

  group('CoreLocalizations fallback without the delegate registered', () {
    testWidgets('a Spanish app shows Spanish, not English', (tester) async {
      await tester.pumpWidget(appWithoutCoreDelegate(const Locale('es')));
      await tester.pump();

      expect(find.text('Cargando...'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('an unsupported locale falls back to English', (tester) async {
      await tester.pumpWidget(appWithoutCoreDelegate(const Locale('fr')));
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('the error state follows the ambient locale too', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: DefaultInitScreen(errorMessage: 'boom', onRetry: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('No se pudo iniciar'), findsOneWidget);
    });
  });

  group('with the delegate registered (the normal path)', () {
    testWidgets('the registered delegate wins', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          supportedLocales: CoreLocalizations.supportedLocales,
          localizationsDelegates: CoreLocalizations.localizationsDelegates,
          home: DefaultInitScreen(onRetry: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('Laden...'), findsOneWidget);
    });
  });
}
