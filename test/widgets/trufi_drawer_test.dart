import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

void main() {
  group("TrufiDrawer", () {
    // TODO: Remove Singleton or make it easier to test, create clean method.
    final trufiCfg = TrufiConfiguration();

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
        const Locale("en"): "Test Trufi App",
      };

      await tester.pumpWidget(BlocProvider<PreferencesBloc>(
        create: (context) => PreferencesBloc(MockSharedPreferencesRepository()),
        child: const MaterialApp(
          localizationsDelegates: [
            TrufiLocalization.delegate,
          ],
          locale: Locale("en"),
          home: TrufiDrawer("/"),
        ),
      ));

      final Finder textFinder = find.text("Test Trufi App");
      expect(textFinder, findsOneWidget);
    });

    testWidgets("should show the real Title", (tester) async {
      trufiCfg.customTranslations.title = null;
      await tester.pumpWidget(BlocProvider<PreferencesBloc>(
        create: (context) => PreferencesBloc(MockSharedPreferencesRepository()),
        child: const MaterialApp(
          localizationsDelegates: [
            TrufiLocalization.delegate,
          ],
          locale: Locale("en"),
          home: TrufiDrawer("/"),
        ),
      ));

      final Finder textFinder = find.text("Trufi App");
      expect(textFinder, findsOneWidget);
    });
  });
}

class MockSharedPreferencesRepository extends Mock
    implements SharedPreferencesRepository {}
