import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

void main() {
  group('MapsLocalizations delegate registration', () {
    testWidgets('MapOnlineOfflineToggle renders English defaults '
        'when the delegate is registered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MapsLocalizations.localizationsDelegates,
          supportedLocales: MapsLocalizations.supportedLocales,
          home: Scaffold(
            body: MapOnlineOfflineToggle(showOnline: true, onToggle: (_) {}),
          ),
        ),
      );

      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('MapOnlineOfflineToggle renders Spanish labels '
        'for a Spanish locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: MapsLocalizations.localizationsDelegates,
          supportedLocales: MapsLocalizations.supportedLocales,
          home: Scaffold(
            body: MapOnlineOfflineToggle(showOnline: true, onToggle: (_) {}),
          ),
        ),
      );

      expect(find.text('En línea'), findsOneWidget);
      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('widgets throw when the delegate is missing '
        '(documented breaking change: no implicit English fallback)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapOnlineOfflineToggle(showOnline: true, onToggle: (_) {}),
          ),
        ),
      );

      expect(tester.takeException(), isA<TypeError>());
    });
  });
}
