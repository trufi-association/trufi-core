import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core/l10n/material_localization_qu.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/trufi_configuration.dart';
import './blocs/app_review_bloc.dart';
import './blocs/bloc_provider.dart';
import './blocs/favorite_locations_bloc.dart';
import './blocs/history_locations_bloc.dart';
import './blocs/location_provider_bloc.dart';
import './blocs/location_search_bloc.dart';
import './blocs/preferences_bloc.dart';
import './blocs/request_manager_bloc.dart';
import './blocs/saved_places_bloc.dart';
import './pages/about.dart';
import './pages/feedback.dart';
import './pages/home.dart';
import './pages/saved_places.dart';
import './pages/team.dart';
import './widgets/trufi_drawer.dart';

class TrufiApp extends StatelessWidget {
  TrufiApp({@required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc();
    return BlocProvider<PreferencesBloc>(
      bloc: preferencesBloc,
      child: BlocProvider<AppReviewBloc>(
        bloc: AppReviewBloc(preferencesBloc),
        child: BlocProvider<RequestManagerBloc>(
          bloc: RequestManagerBloc(preferencesBloc),
          child: BlocProvider<LocationProviderBloc>(
            bloc: LocationProviderBloc(),
            child: BlocProvider<LocationSearchBloc>(
              bloc: LocationSearchBloc(context),
              child: BlocProvider<FavoriteLocationsBloc>(
                bloc: FavoriteLocationsBloc(context),
                child: BlocProvider<HistoryLocationsBloc>(
                  bloc: HistoryLocationsBloc(context),
                  child: BlocProvider<SavedPlacesBloc>(
                    bloc: SavedPlacesBloc(context),
                    child: AppLifecycleReactor(
                      child: LocalizedMaterialApp(theme),
                    ),
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
  LocalizedMaterialApp(this.theme);

  final ThemeData theme;

  @override
  _LocalizedMaterialAppState createState() => _LocalizedMaterialAppState();
}

class _LocalizedMaterialAppState extends State<LocalizedMaterialApp> {
  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final routes = <String, WidgetBuilder>{
      AboutPage.route: (context) => AboutPage(),
      FeedbackPage.route: (context) => FeedbackPage(),
      SavedPlacesPage.route: (context) => SavedPlacesPage(),
      TeamPage.route: (context) => TeamPage(),
    };

    return StreamBuilder(
      stream: preferencesBloc.outChangeLanguageCode,
      initialData: TrufiConfiguration()
              .languages
              .firstWhere((element) => element.isDefault)
              .languageCode ??
          "en",
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot.data);
        return MaterialApp(
          locale: Locale.fromSubtags(languageCode: snapshot.data),
          onGenerateRoute: (settings) {
            return new TrufiDrawerRoute(
              builder: routes[settings.name],
              settings: settings,
            );
          },
          localizationsDelegates: [
            TrufiLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            QuMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: TrufiLocalization.supportedLocales,
          debugShowCheckedModeBanner: true,
          theme: widget.theme,
          home: HomePage(),
        );
      },
    );
  }
}
