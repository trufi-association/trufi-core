import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';

/// trufi-core#1002: the notes block of a [FareCard] follows
/// [FareInfo.notesBuilder] per locale; the plain [FareInfo.notes] stay the
/// fallback for apps that never set a builder.
const _notesByLanguage = {'en': 'English notes', 'es': 'Notas en español'};

String _localizedNotes(BuildContext context) =>
    _notesByLanguage[Localizations.localeOf(context).languageCode]!;

const _primary = FareCategory(label: 'General', price: '3.00');

Widget _host(FareInfo fare, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: FaresLocalizations.supportedLocales,
  localizationsDelegates: FaresLocalizations.localizationsDelegates,
  home: Scaffold(
    body: FareCard(fare: fare, currency: 'Bs.'),
  ),
);

void main() {
  testWidgets('renders the notes the builder returns for the locale', (
    tester,
  ) async {
    final fare = FareInfo(
      title: 'Urban',
      icon: Icons.directions_bus_rounded,
      primary: _primary,
      notes: 'Notas en español',
      notesBuilder: _localizedNotes,
    );

    await tester.pumpWidget(_host(fare, locale: 'en'));
    expect(find.text('English notes'), findsOneWidget);
    expect(find.text('Notas en español'), findsNothing);

    await tester.pumpWidget(_host(fare, locale: 'es'));
    expect(find.text('Notas en español'), findsOneWidget);
    expect(find.text('English notes'), findsNothing);
  });

  testWidgets('shows the notes block when only the builder is set', (
    tester,
  ) async {
    final fare = FareInfo(
      title: 'Urban',
      icon: Icons.directions_bus_rounded,
      primary: _primary,
      notesBuilder: _localizedNotes,
    );

    await tester.pumpWidget(_host(fare));

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.text('English notes'), findsOneWidget);
  });

  testWidgets('plain notes still render without a builder', (tester) async {
    const fare = FareInfo(
      title: 'Urban',
      icon: Icons.directions_bus_rounded,
      primary: _primary,
      notes: 'Plain notes',
    );

    await tester.pumpWidget(_host(fare));

    expect(find.text('Plain notes'), findsOneWidget);
  });

  testWidgets('no notes at all hides the notes block', (tester) async {
    const fare = FareInfo(
      title: 'Urban',
      icon: Icons.directions_bus_rounded,
      primary: _primary,
    );

    await tester.pumpWidget(_host(fare));

    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
}
