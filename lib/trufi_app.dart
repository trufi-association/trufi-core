import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/app_review_bloc.dart';
import 'package:trufi_core/blocs/home_page_bloc.dart';
import 'package:trufi_core/blocs/request_manager_bloc.dart';
import 'package:trufi_core/l10n/material_localization_qu.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/pages/home_page.dart';
import 'package:trufi_core/repository/offline_repository.dart';
import 'package:trufi_core/repository/online_repository.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_observer.dart';
import 'package:trufi_core/widgets/app_review_dialog.dart';

import './blocs/bloc_provider.dart';
import './blocs/favorite_locations_bloc.dart';
import './blocs/history_locations_bloc.dart';
import './blocs/location_provider_bloc.dart';
import './blocs/location_search_bloc.dart';
import './blocs/preferences_bloc.dart';
import './blocs/saved_places_bloc.dart';
import './pages/about.dart';
import './pages/feedback.dart';
import './pages/saved_places.dart';
import './pages/team.dart';
import './widgets/trufi_drawer.dart';

/// Signature for a function that creates a widget with the current [Locale],
/// e.g. [StatelessWidget.build] or [State.build].
///
/// See also:
///
///  * [IndexedWidgetBuilder], which is similar but also takes an index.
///  * [TransitionBuilder], which is similar but also takes a child.
///  * [ValueWidgetBuilder], which is similar but takes a value and a child.
typedef LocaleWidgetBuilder = Widget Function(
    BuildContext context, Locale locale);

/// The [TrufiApp] is the main Widget of the application
///
/// The [customOverlayBuilder] allows you to add an host controlled overlay
/// on top of the Trufi Map. It is located from the left side of the screen
/// until the beginning of the Fab buttons.
///
/// Starting from the Fab buttons you are able to add the [customBetweenFabBuilder]
/// to add a customOverlay between the two Fab Buttons on the right side.
///
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     return TrufiApp(
///       theme: theme,
///       customOverlayBuilder: (context, locale) => Placeholder(),
///       customBetweenFabBuilder: (context) => Placeholder(),
///     ),
///   }
/// ```
///
class TrufiApp extends StatelessWidget {
  TrufiApp(
      {@required this.theme,
      this.customOverlayBuilder,
      this.customBetweenFabBuilder,
      Key key})
      : super(key: key) {
    if (TrufiConfiguration().generalConfiguration.debug) {
      Bloc.observer = TrufiObserver();
    }
  }

  /// The used [ThemeData] used for the whole Trufi App
  final ThemeData theme;

  /// A [customOverlayBuilder] that receives the current language to allow
  /// a custom overlay on top of the Trufi Core.
  final LocaleWidgetBuilder customOverlayBuilder;

  /// The [customBetweenFabBuilder] is [Builder] that allows creating a overlay
  /// in between the Fab buttons of the Trufi Core.
  final WidgetBuilder customBetweenFabBuilder;

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesRepository = SharedPreferencesRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<PreferencesCubit>(
          create: (context) => PreferencesCubit(sharedPreferencesRepository),
        ),
        BlocProvider<AppReviewCubit>(
          create: (context) => AppReviewCubit(sharedPreferencesRepository),
        ),
        BlocProvider<RequestManagerBloc>(
          create: (context) => RequestManagerBloc(
            OfflineRepository(),
            OnlineRepository(),
          ),
        ),
        BlocProvider<HomePageBloc>(
          create: (context) => HomePageBloc(sharedPreferencesRepository),
        )
      ],
      child: TrufiBlocProvider<LocationProviderBloc>(
        bloc: LocationProviderBloc(),
        child: TrufiBlocProvider<LocationSearchBloc>(
          bloc: LocationSearchBloc(context),
          child: TrufiBlocProvider<FavoriteLocationsBloc>(
            bloc: FavoriteLocationsBloc(context),
            child: TrufiBlocProvider<HistoryLocationsBloc>(
              bloc: HistoryLocationsBloc(context),
              child: TrufiBlocProvider<SavedPlacesBloc>(
                bloc: SavedPlacesBloc(context),
                child: AppLifecycleReactor(
                  child: LocalizedMaterialApp(
                    theme,
                    customOverlayBuilder,
                    customBetweenFabBuilder,
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
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final locationProviderBloc = LocationProviderBloc.of(context);

    if (state == AppLifecycleState.resumed) {
      final appReviewBloc = BlocProvider.of<AppReviewCubit>(context);
      final packageInfo = await PackageInfo.fromPlatform();
      if (await appReviewBloc.isAppReviewAppropriate(packageInfo)) {
        showAppReviewDialog(context);
        appReviewBloc.markReviewRequestedForCurrentVersion(packageInfo);
      }
    }

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
  const LocalizedMaterialApp(
      this.theme, this.customOverlayWidget, this.customBetweenFabWidget,
      {Key key})
      : super(key: key);

  final ThemeData theme;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  @override
  _LocalizedMaterialAppState createState() => _LocalizedMaterialAppState();
}

class _LocalizedMaterialAppState extends State<LocalizedMaterialApp> {
  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      AboutPage.route: (context) => const AboutPage(),
      FeedbackPage.route: (context) => const FeedbackPage(),
      SavedPlacesPage.route: (context) => const SavedPlacesPage(),
      TeamPage.route: (context) => const TeamPage(),
    };

    return BlocBuilder<PreferencesCubit, Preference>(
      builder: (BuildContext context, state) {
        return MaterialApp(
          locale: Locale.fromSubtags(languageCode: state.languageCode),
          onGenerateRoute: (settings) {
            return TrufiDrawerRoute(
              builder: routes[settings.name],
              settings: settings,
            );
          },
          localizationsDelegates: const [
            TrufiLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            QuMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: TrufiLocalization.supportedLocales,
          theme: widget.theme,
          home: HomePage(
            customOverlayWidget: widget.customOverlayWidget,
            customBetweenFabWidget: widget.customBetweenFabWidget,
          ),
        );
      },
    );
  }
}
