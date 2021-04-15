import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:trufi_core/location/location_form_field.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/trufi_configuration.dart';

void main() {
  testWidgets('Trufi App - Home Widget', (WidgetTester tester) async {
    final trufiCfg = TrufiConfiguration();

    trufiCfg.languages.addAll([
      TrufiConfigurationLanguage(
        languageCode: "en",
        countryCode: "US",
        displayName: "English",
        isDefault: true,
      ),
    ]);

    await mockNetworkImagesFor(() async => await tester.pumpWidget(TrufiApp(
          theme: ThemeData(
            primaryColor: const Color(0xff263238),
            primaryColorLight: const Color(0xffeceff1),
            accentColor: const Color(0xffd81b60),
            backgroundColor: Colors.white,
          ),
        )));

    await tester.pumpAndSettle();
    final Finder formField = find.byType(LocationFormField);
    expect(formField, findsNWidgets(2));
  });

  testWidgets("should display customBetweenFabWidget Widget if provided",
      (WidgetTester tester) async {
    await tester.pumpWidget(TrufiApp(
      theme: ThemeData.light(),
      customBetweenFabBuilder: (context) => Placeholder(),
    ));

    await tester.pumpAndSettle();

    Finder findPlaceholder = find.byType(Placeholder);
    expect(findPlaceholder, findsOneWidget);
  });

  testWidgets("should display customWidget with Locale Text",
      (WidgetTester tester) async {
    await tester.pumpWidget(TrufiApp(
      theme: ThemeData.light(),
      customOverlayBuilder: (context, locale) =>
          Text("${locale.languageCode}_${locale.countryCode}"),
    ));

    await tester.pumpAndSettle();

    Finder findText = find.text("en_null");
    expect(findText, findsOneWidget);
  });
}

class HomeRobot {
  HomeRobot seesMyLocationFab() {
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    return this;
  }

  HomeRobot seesAppBar() {
    final Finder formField = find.byType(AppBar);
    expect(formField, findsOneWidget);
    return this;
  }

  HomeRobot seesFormFields() {
    final Finder formField = find.byType(LocationFormField);
    expect(formField, findsNWidgets(2));
    return this;
  }
}
