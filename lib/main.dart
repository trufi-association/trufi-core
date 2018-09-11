import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_app/app_builder.dart';
import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/trufi_localizations.dart';

void main() {
  runApp(BlocProvider<LocationProviderBloc>(
    bloc: LocationProviderBloc(),
    child: BlocProvider<FavoriteLocationsBloc>(
      bloc: FavoriteLocationsBloc(),
      child: BlocProvider<HistoryLocationsBloc>(
        bloc: HistoryLocationsBloc(),
        child: TrufiApp(),
      ),
    ),
  ));
}

class TrufiApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrufiAppState();
  }

  static TrufiAppState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<TrufiAppState>());
  }
}

class TrufiAppState extends State<TrufiApp> {
  TrufiLocalizationsDelegate localizationsDelegate;

  @override
  void initState() {
    super.initState();
    localizationsDelegate = TrufiLocalizationsDelegate();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(primaryColor: const Color(0xffffd600));
    return AppBuilder(builder: (context) {
      return MaterialApp(
        routes: <String, WidgetBuilder>{
          AboutPage.route: (context) => AboutPage(),
          FeedbackPage.route: (context) => FeedbackPage()
        },
        localizationsDelegates: [
          localizationsDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('de', 'DE'), // German
          const Locale('es', 'ES'), // Spanish
          // ... other locales the app supports
        ],
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: HomePage(),
      );
    });
  }

  void rebuild() {
    setState(() {});
  }
}
