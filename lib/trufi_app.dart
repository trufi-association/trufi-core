import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/l10n/material_localization_qu.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/server_type.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/pages/home/setting_payload/setting_panel/setting_panel.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_observer.dart';

import './blocs/bloc_provider.dart';
import './blocs/location_search_bloc.dart';
import './blocs/preferences/preferences_cubit.dart';
import './pages/about.dart';
import './pages/feedback.dart';
import './pages/saved_places/saved_places.dart';
import './pages/team.dart';
import './widgets/trufi_drawer.dart';
import 'blocs/custom_layer/custom_layers_cubit.dart';
import 'blocs/gps_location/location_provider_cubit.dart';
import 'blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'blocs/search_locations/search_locations_cubit.dart';
import 'models/custom_layer.dart';
import 'models/map_tile_provider.dart';
import 'pages/app_lifecycle_reactor.dart';
import 'services/plan_request/online_graphql_repository/online_graphql_repository.dart';
import 'services/plan_request/online_repository.dart';
import 'services/search_location/offline_search_location.dart';
import 'services/search_location/search_location_manager.dart';

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
    @required this.configuration,
    @required this.theme,
    this.searchTheme,
    this.customOverlayBuilder,
    this.customBetweenFabBuilder,
    Key key,
    this.customLayers = const [],
    this.mapTileProviders,
    this.searchLocationManager,
    this.socialMediaItem = const [],
  })  : assert(configuration != null, "Configuration cannot be empty"),
        assert(theme != null, "Theme cannot be empty"),
        super(key: key) {
    if (configuration.debug) {
      Bloc.observer = TrufiObserver();
    }
  }

  /// Main Configurations for the TrufiCore it contains information about
  /// Feedback, Emails and Contributors.
  final Configuration configuration;

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

  ///List of [SocialMediaItem] implementations
  ///By defaul [Trufi-Core] has some implementation what you can use:
  /// [FacebookSocialMedia] [InstagramSocialMedia] [TwitterSocialMedia]
  final List<SocialMediaItem> socialMediaItem;

  /// List of Map Tile Provider
  /// if the list is [null] or [Empty], [Trufi Core] then will be used [OSMDefaultMapTile]
  final List<MapTileProvider> mapTileProviders;

  ///You can provider a [SearchLocationManager]
  ///By defaul [Trufi-Core] has implementation
  /// [OfflineSearchLocation] that used the assets/data/search.json
  final SearchLocationManager searchLocationManager;

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesRepository = SharedPreferencesRepository();
    final openTripPlannerUrl = configuration.urls.openTripPlannerUrl;
    final serverType = configuration.serverType;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConfigurationCubit>(
          create: (context) => ConfigurationCubit(configuration),
        ),
        BlocProvider<PreferencesCubit>(
          create: (context) => PreferencesCubit(socialMediaItem),
        ),
        BlocProvider<CustomLayersCubit>(
          create: (context) => CustomLayersCubit(customLayers),
        ),
        BlocProvider<MapTileProviderCubit>(
          create: (context) => MapTileProviderCubit(
            mapTileProviders:
                mapTileProviders != null && mapTileProviders.isNotEmpty
                    ? mapTileProviders
                    : [OSMDefaultMapTile()],
          ),
        ),
        BlocProvider<AppReviewCubit>(
          create: (context) => AppReviewCubit(
            configuration.minimumReviewWorthyActionCount,
            sharedPreferencesRepository,
          ),
        ),
        BlocProvider<SearchLocationsCubit>(
          create: (context) => SearchLocationsCubit(
            searchLocationManager ?? OfflineSearchLocation(),
          ),
        ),
        BlocProvider<HomePageCubit>(
          create: (context) {
            return HomePageCubit(
              sharedPreferencesRepository,
              serverType == ServerType.defaultServer
                  ? OnlineRepository(
                      otpEndpoint: openTripPlannerUrl,
                    )
                  : OnlineGraphQLRepository(
                      graphQLEndPoint: openTripPlannerUrl,
                    ),
            );
          },
        ),
        BlocProvider<LocationProviderCubit>(
          create: (context) => LocationProviderCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(theme, searchTheme),
        ),
        BlocProvider<PayloadDataPlanCubit>(
          create: (context) =>
              PayloadDataPlanCubit(sharedPreferencesRepository),
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
      TeamPage.route: (context) => TeamPage(),
      SettingPanel.route: (context) => const SettingPanel(),
    };

    return BlocBuilder<PreferencesCubit, PreferenceState>(
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
            GlobalCupertinoLocalizations.delegate,
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
