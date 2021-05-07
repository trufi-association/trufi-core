import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/l10n/material_localization_qu.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_observer.dart';
import 'package:uuid/uuid.dart';

import './blocs/bloc_provider.dart';
import './blocs/location_search_bloc.dart';
import './blocs/preferences_cubit.dart';
import './pages/about.dart';
import './pages/feedback.dart';
import './pages/saved_places.dart';
import './pages/team.dart';
import './widgets/trufi_drawer.dart';
import 'blocs/custom_layer/custom_layers_cubit.dart';
import 'blocs/gps_location/location_provider_cubit.dart';
import 'blocs/search_locations/search_locations_cubit.dart';
import 'models/custom_layer.dart';
import 'pages/app_lifecycle_reactor.dart';
import 'pages/home/plan_map/setting_panel/setting_panel.dart';
import 'pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'services/plan_request/online_graphql_repository/online_graphql_repository.dart';
import 'services/plan_request/online_repository.dart';
import 'services/search_location/offline_search_location.dart';

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
  TrufiApp({
    @required this.theme,
    this.searchTheme,
    this.customOverlayBuilder,
    this.customBetweenFabBuilder,
    Key key,
    this.customLayers = const [],
    this.feedBack,
  }) : super(key: key) {
    if (TrufiConfiguration().generalConfiguration.debug) {
      Bloc.observer = TrufiObserver();
    }
  }

  /// The used [ThemeData] used for the whole Trufi App
  final ThemeData theme;

  /// The used ThemeData for the SearchDelegate
  final ThemeData searchTheme;

  /// A [customOverlayBuilder] that receives the current language to allow
  /// a custom overlay on top of the Trufi Core.
  final LocaleWidgetBuilder customOverlayBuilder;

  /// The [customBetweenFabBuilder] is [Builder] that allows creating a overlay
  /// in between the Fab buttons of the Trufi Core.
  final WidgetBuilder customBetweenFabBuilder;

  /// List of [CustomLayer] implementations
  final List<CustomLayer> customLayers;

  /// You can provider a [DefinitionDataFeedBack] for add the feedbackPage
  /// if the FeedBack is null, the comment page is not created.
  final DefinitionFeedBack feedBack;

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesRepository = SharedPreferencesRepository();
    final trufiConfiguration = TrufiConfiguration();
    trufiConfiguration.configurationDrawer.definitionFeedBack = feedBack;
    return MultiBlocProvider(
      providers: [
        BlocProvider<PreferencesCubit>(
          create: (context) => PreferencesCubit(
            sharedPreferencesRepository,
            Uuid(),
          ),
        ),
        BlocProvider<CustomLayersCubit>(
          create: (context) => CustomLayersCubit(customLayers),
        ),
        BlocProvider<AppReviewCubit>(
          create: (context) => AppReviewCubit(sharedPreferencesRepository),
        ),
        BlocProvider<SearchLocationsCubit>(
          create: (context) => SearchLocationsCubit(
            OfflineSearchLocation(),
          ),
        ),
        BlocProvider<HomePageCubit>(
          create: (context) => HomePageCubit(
            sharedPreferencesRepository,
            trufiConfiguration.generalConfiguration.serverType == ServerType.defaultServer
                ? OnlineRepository(
                    otpEndpoint: trufiConfiguration.url.otpEndpoint,
                  )
                : OnlineGraphQLRepository(
                    graphQLEndPoint: trufiConfiguration.url.otpEndpoint,
                  ),
          ),
        ),
        BlocProvider<LocationProviderCubit>(
          create: (context) => LocationProviderCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(theme, searchTheme),
        ),
        BlocProvider<SettingPanelCubit>(
          create: (context) => SettingPanelCubit(sharedPreferencesRepository),
          lazy: false,
        ),
      ],
      child: TrufiBlocProvider<LocationSearchBloc>(
        bloc: LocationSearchBloc(context),
        child: AppLifecycleReactor(
          child: LocalizedMaterialApp(
            customOverlayBuilder,
            customBetweenFabBuilder,
          ),
        ),
      ),
    );
  }
}

class LocalizedMaterialApp extends StatelessWidget {
  const LocalizedMaterialApp(
      this.customOverlayWidget, this.customBetweenFabWidget,
      {Key key})
      : super(key: key);

  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      AboutPage.route: (context) => const AboutPage(),
      FeedbackPage.route: (context) => const FeedbackPage(),
      SavedPlacesPage.route: (context) => const SavedPlacesPage(),
      TeamPage.route: (context) => const TeamPage(),
      SettingPanel.route: (context) => const SettingPanel(),
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
          theme: context.watch<ThemeCubit>().state.activeTheme,
          home: HomePage(
            customOverlayWidget: customOverlayWidget,
            customBetweenFabWidget: customBetweenFabWidget,
          ),
        );
      },
    );
  }
}
