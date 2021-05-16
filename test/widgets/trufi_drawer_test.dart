import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

void main() {
  group("TrufiDrawer", () {
    testWidgets("should show the customTranslated Title", (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<PreferencesCubit>(
              create: (context) => PreferencesCubit([]),
            ),
            BlocProvider<ConfigurationCubit>(
              create: (context) => ConfigurationCubit(
                Configuration(
                    supportedLanguages: [
                      LanguageConfiguration("en", "", "English",
                          isDefault: true),
                    ],
                    customTranslations: TrufiCustomLocalizations()
                      ..title = {const Locale("en"): "Test Trufi App"},
                    urls: UrlCollection()),
              ),
            )
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              TrufiLocalization.delegate,
            ],
            locale: Locale("en"),
            home: TrufiDrawer("/"),
          ),
        ),
      );

      final Finder textFinder = find.text("Test Trufi App");
      expect(textFinder, findsOneWidget);
    });

    testWidgets("should show the real Title", (tester) async {
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<PreferencesCubit>(
            create: (context) => PreferencesCubit([]),
          ),
          BlocProvider<ConfigurationCubit>(
            create: (context) => ConfigurationCubit(
              Configuration(
                  supportedLanguages: [
                    LanguageConfiguration("en", "", "English", isDefault: true),
                  ],
                  customTranslations: TrufiCustomLocalizations()..title = null,
                  urls: UrlCollection()),
            ),
          )
        ],
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
