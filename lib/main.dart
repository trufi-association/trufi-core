import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/place_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/blocs/search_locations_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

void main() {
  runApp(TrufiApp());
}

class TrufiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc();
    return BlocProvider<PreferencesBloc>(
      bloc: preferencesBloc,
      child: BlocProvider<RequestManagerBloc>(
        bloc: RequestManagerBloc(preferencesBloc),
        child: BlocProvider<LocationProviderBloc>(
          bloc: LocationProviderBloc(),
          child: BlocProvider<FavoriteLocationsBloc>(
            bloc: FavoriteLocationsBloc(context),
            child: BlocProvider<HistoryLocationsBloc>(
              bloc: HistoryLocationsBloc(context),
              child: BlocProvider<PlaceLocationsBloc>(
                bloc: PlaceLocationsBloc(context),
                child: BlocProvider<SearchLocationsBloc>(
                  bloc: SearchLocationsBloc(context),
                  child: AppLifecycleReactor(
                    child: LocalizedMaterialApp(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    print("AppLifecycleState: $state");
    setState(() {
      _notification = state;
      if (_notification == AppLifecycleState.resumed) {
        locationProviderBloc.start();
      } else {
        locationProviderBloc.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LocalizedMaterialApp extends StatefulWidget {
  @override
  _LocalizedMaterialAppState createState() => _LocalizedMaterialAppState();
}

class _LocalizedMaterialAppState extends State<LocalizedMaterialApp> {
  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xffffd606),
      primaryIconTheme: const IconThemeData(color: Colors.black),
    );
    final routes = <String, WidgetBuilder>{
      AboutPage.route: (context) => AboutPage(),
      FeedbackPage.route: (context) => FeedbackPage(),
      TeamPage.route: (context) => TeamPage(),
    };
    return StreamBuilder(
      stream: preferencesBloc.outChangeLanguageCode,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return MaterialApp(
          onGenerateRoute: (settings) {
            return new TrufiDrawerRoute(
              builder: routes[settings.name],
              settings: settings,
            );
          },
          localizationsDelegates: [
            TrufiLocalizationsDelegate(snapshot.data),
            TrufiMaterialLocalizationsDelegate(snapshot.data),
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: HomePage(),
        );
      },
    );
  }
}
