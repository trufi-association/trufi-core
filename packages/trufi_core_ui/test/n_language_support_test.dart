import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_ui/src/l10n/fallback_material_localizations.dart';

/// Trufi ships in whatever languages a city translates it into — including
/// ones Flutter itself doesn't know (Quechua, Aymara, Guaraní). These tests
/// pin that promise: the framework must keep working for such a locale.
void main() {
  const quechua = Locale('qu');

  group('framework localizations for city languages', () {
    testWidgets(
      'a Quechua app builds a Scaffold instead of asserting',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: quechua,
            supportedLocales: const [quechua, Locale('es')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              ...fallbackFrameworkLocalizationsDelegates(),
            ],
            home: const Scaffold(body: Text('Allinllachu')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Allinllachu'), findsOneWidget);
        // Framework strings fall back, but they exist — that is the point.
        final context = tester.element(find.byType(Scaffold));
        expect(MaterialLocalizations.of(context), isNotNull);
      },
    );

    testWidgets('Flutter-supported locales still get their own translations', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          supportedLocales: const [Locale('de'), quechua],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            ...fallbackFrameworkLocalizationsDelegates(),
          ],
          home: const Scaffold(body: SizedBox()),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      // "Zurück" — proof the real German delegate wins over the fallback,
      // which is registered last precisely so it never shadows a real one.
      expect(MaterialLocalizations.of(context).backButtonTooltip, 'Zurück');
    });
  });
}
