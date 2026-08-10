import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// The engine picker shows `localizedName`/`localizedDescription`; when a
/// city doesn't pass a display name, the default must come from
/// MapsLocalizations instead of a hardcoded English literal (#945).
void main() {
  Future<BuildContext> contextWithLocale(
    WidgetTester tester,
    Locale locale,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: MapsLocalizations.localizationsDelegates,
        supportedLocales: MapsLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return captured;
  }

  const bareEngine = MapLibreEngine(styleString: 'https://example.com/style');

  group('MapLibreEngine.localizedName default', () {
    testWidgets('is localized for Spanish', (tester) async {
      final context = await contextWithLocale(tester, const Locale('es'));
      expect(bareEngine.localizedName(context), 'Mapa vectorial (MapLibre)');
    });

    testWidgets('keeps the historical English text', (tester) async {
      final context = await contextWithLocale(tester, const Locale('en'));
      expect(bareEngine.localizedName(context), 'Vector (MapLibre)');
    });

    testWidgets('displayName still wins over the localized default', (
      tester,
    ) async {
      const engine = MapLibreEngine(
        styleString: 'https://example.com/style',
        displayName: 'Liberty',
      );
      final context = await contextWithLocale(tester, const Locale('es'));
      expect(engine.localizedName(context), 'Liberty');
    });

    testWidgets('nameBuilder wins over everything', (tester) async {
      final engine = MapLibreEngine(
        styleString: 'https://example.com/style',
        displayName: 'Liberty',
        nameBuilder: (_) => 'Ciudad',
      );
      final context = await contextWithLocale(tester, const Locale('es'));
      expect(engine.localizedName(context), 'Ciudad');
    });
  });
}
