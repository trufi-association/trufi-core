import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

void main() {
  Widget buildBar() => Scaffold(
    body: SearchLocationBar(
      state: const SearchLocationState(),
      onSearch: ({required bool isOrigin}) async => null,
      onOriginSelected: (_) {},
      onDestinationSelected: (_) {},
    ),
  );

  group('SearchLocationsLocalizations delegate registration', () {
    testWidgets('SearchLocationBar renders English defaults '
        'when the delegate is registered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates:
              SearchLocationsLocalizations.localizationsDelegates,
          supportedLocales: SearchLocationsLocalizations.supportedLocales,
          home: buildBar(),
        ),
      );

      expect(find.text('Select origin'), findsOneWidget);
      expect(find.text('Select destination'), findsOneWidget);
    });

    testWidgets('SearchLocationBar renders Spanish hints '
        'for a Spanish locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates:
              SearchLocationsLocalizations.localizationsDelegates,
          supportedLocales: SearchLocationsLocalizations.supportedLocales,
          home: buildBar(),
        ),
      );

      expect(find.text('Seleccionar origen'), findsOneWidget);
      expect(find.text('Seleccionar destino'), findsOneWidget);
    });

    testWidgets('widgets throw when the delegate is missing '
        '(documented breaking change: no implicit English fallback)', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: buildBar()));

      expect(tester.takeException(), isA<TypeError>());
    });
  });
}
