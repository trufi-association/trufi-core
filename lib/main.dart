import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_material_localizations.dart';

void main() {
  runApp(TrufiApp());
}

class TrufiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xffffd600),
      primaryIconTheme: const IconThemeData(color: Colors.black),
    );
    return BlocProvider<LocationProviderBloc>(
      bloc: LocationProviderBloc(),
      child: BlocProvider<FavoriteLocationsBloc>(
        bloc: FavoriteLocationsBloc(context),
        child: BlocProvider<HistoryLocationsBloc>(
          bloc: HistoryLocationsBloc(context),
          child: BlocProvider<ImportantLocationsBloc>(
            bloc: ImportantLocationsBloc(context),
            child: MaterialApp(
              routes: <String, WidgetBuilder>{
                AboutPage.route: (context) => AboutPage(),
                FeedbackPage.route: (context) => FeedbackPage(),
                TeamPage.route: (context) => TeamPage(),
              },
              localizationsDelegates: [
                TrufiLocalizationsDelegate(),
                TrufiMaterialLocalizationsDelegate(),
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en', 'US'), // English
                const Locale('de', 'DE'), // German
                const Locale('es', 'ES'), // Spanish
                const Locale('qu', 'BO'), // Quechua
                // ... other locales the app supports
              ],
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: HomePage(),
            ),
          ),
        ),
      ),
    );
  }
}
