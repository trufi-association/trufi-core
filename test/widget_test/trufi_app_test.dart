import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/location/location_form_field.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_localizations.dart';

import '../image_tile.dart';
import '../mock_http_client.dart';

void main() {
  setUp(() async {
    HttpOverrides.global = new TestHttpOverrides({
      Uri.parse('https://maps.tilehosting.com/styles/positron/5/17/tile.png'):
          dummyImageData
    });
  });

  group("Trufi App", () {
    setUp(() {
      final trufiCfg = TrufiConfiguration();
      trufiCfg.languages.addAll([
        TrufiConfigurationLanguage(
          languageCode: "en",
          countryCode: "US",
          displayName: "English",
        ),
      ]);
    });

    testWidgets('should be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(TrufiApp(
        theme: ThemeData(
          primaryColor: const Color(0xff263238),
          primaryColorLight: const Color(0xffeceff1),
          accentColor: const Color(0xffd81b60),
          backgroundColor: Colors.white,
        ),
        localization: const TrufiLocalizationDefault(),
      ));

      await tester.pumpAndSettle();
      final Finder formField = find.byType(LocationFormField);
      expect(formField, findsNWidgets(2));
    });

    testWidgets("should display customBetweenFabWidget Widget if provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(TrufiApp(
        theme: null,
        customBetweenFabBuilder: (context) => Placeholder(),
      ));

      await tester.pumpAndSettle();

      Finder findPlaceholder = find.byType(Placeholder);
      expect(findPlaceholder, findsOneWidget);
    });

    testWidgets("should display customWidget with Locale Text",
        (WidgetTester tester) async {
      await tester.pumpWidget(TrufiApp(
        theme: null,
        customOverlayBuilder: (context, locale) => Text(
          "${locale.countryCode} ${locale.languageCode}",
        ),
      ));

      await tester.pumpAndSettle();

      Finder findText = find.text("US en");
      expect(findText, findsOneWidget);
    });
  });
}
