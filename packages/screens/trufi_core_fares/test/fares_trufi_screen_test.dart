import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';

/// trufi-core#1002: the tips card at the bottom of [FaresTrufiScreen]
/// follows [FaresConfig.additionalNotesBuilder] per locale; the plain
/// [FaresConfig.additionalNotes] stay the fallback for apps without one.
const _tipsByLanguage = {'en': 'English tips', 'es': 'Consejos en español'};

String _localizedTips(BuildContext context) =>
    _tipsByLanguage[Localizations.localeOf(context).languageCode]!;

const _fares = [
  FareInfo(
    title: 'Urban',
    icon: Icons.directions_bus_rounded,
    primary: FareCategory(label: 'General', price: '3.00'),
  ),
];

Widget _host(FaresConfig config, {String locale = 'en'}) {
  final screen = FaresTrufiScreen(config: config);
  return MaterialApp(
    locale: Locale(locale),
    supportedLocales: FaresLocalizations.supportedLocales,
    localizationsDelegates: FaresLocalizations.localizationsDelegates,
    home: Scaffold(body: Builder(builder: screen.builder)),
  );
}

void main() {
  testWidgets('the tips card shows the builder text for the locale', (
    tester,
  ) async {
    final config = FaresConfig(
      currency: 'Bs.',
      fares: _fares,
      additionalNotes: 'Consejos en español',
      additionalNotesBuilder: _localizedTips,
    );

    await tester.pumpWidget(_host(config, locale: 'en'));
    await tester.pumpAndSettle();
    expect(find.text('English tips'), findsOneWidget);
    expect(find.text('Consejos en español'), findsNothing);

    await tester.pumpWidget(_host(config, locale: 'es'));
    await tester.pumpAndSettle();
    expect(find.text('Consejos en español'), findsOneWidget);
    expect(find.text('English tips'), findsNothing);
  });

  testWidgets('the tips card appears when only the builder is set', (
    tester,
  ) async {
    final config = FaresConfig(
      currency: 'Bs.',
      fares: _fares,
      additionalNotesBuilder: _localizedTips,
    );

    await tester.pumpWidget(_host(config));
    await tester.pumpAndSettle();

    expect(find.byType(FaresNotesCard), findsOneWidget);
    expect(find.text('English tips'), findsOneWidget);
  });

  testWidgets('plain additionalNotes still render without a builder', (
    tester,
  ) async {
    const config = FaresConfig(
      currency: 'Bs.',
      fares: _fares,
      additionalNotes: 'Plain tips',
    );

    await tester.pumpWidget(_host(config));
    await tester.pumpAndSettle();

    expect(find.text('Plain tips'), findsOneWidget);
  });

  testWidgets('no additional notes hides the tips card', (tester) async {
    const config = FaresConfig(currency: 'Bs.', fares: _fares);

    await tester.pumpWidget(_host(config));
    await tester.pumpAndSettle();

    expect(find.byType(FaresNotesCard), findsNothing);
  });
}
