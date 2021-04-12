import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/blocs/bloc_provider.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

void main() {
  group("TrufiDrawer", () {
    // TODO: Remove Singleton or make it easier to test, create clean method.
    var trufiCfg = TrufiConfiguration();

    setUpAll(() {
      trufiCfg.image.drawerBackground = "assets/images/drawer-bg.jpg";
      trufiCfg.languages.add(
        TrufiConfigurationLanguage(
          languageCode: "en",
          countryCode: "",
          displayName: "English",
        ),
      );
    });

    testWidgets("should show the customTranslated Title", (tester) async {
      trufiCfg.customTranslations.title = {
        "en": "Test Trufi App",
      };

      await tester.pumpWidget(BlocProvider<PreferencesBloc>(
        bloc: PreferencesBloc(),
        child: MaterialApp(
          localizationsDelegates: [
            TrufiLocalization.delegate,
          ],
          locale: Locale("en"),
          home: TrufiDrawer("/"),
        ),
      ));

      Finder textFinder = find.text("Test Trufi App");
      expect(textFinder, findsOneWidget);
    });

    testWidgets("should show the real Title", (tester) async {
      trufiCfg.customTranslations.title = null;
      await tester.pumpWidget(BlocProvider<PreferencesBloc>(
        bloc: PreferencesBloc(),
        child: MaterialApp(
          localizationsDelegates: [
            TrufiLocalization.delegate,
          ],
          locale: Locale("en"),
          home: TrufiDrawer("/"),
        ),
      ));

      Finder textFinder = find.text("Trufi App");
      expect(textFinder, findsOneWidget);
    });
  });
}
