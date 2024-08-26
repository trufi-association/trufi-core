import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/transport_list_detail.dart';
import 'package:trufi_core/base/widgets/drawer/menu/menu_item.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/drawer/trufi_drawer.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/repository/search_location/default_search_location.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/transport_list/route_transports_cubit/route_transports_cubit.dart';
import 'base/pages/home/widgets/trufi_map_route/trufi_map_route.dart';

abstract class DefaultValues {
  static TrufiLocalization trufiLocalization({Locale? currentLocale}) =>
      TrufiLocalization(
        currentLocale: currentLocale ?? const Locale("en"),
        localizationDelegates: const [
          SavedPlacesLocalization.delegate,
          FeedbackLocalization.delegate,
          AboutLocalization.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en'),
          Locale('es'),
        ],
      );

  static List<BlocProvider> blocProviders({
    required String otpEndpoint,
    required String otpGraphqlEndpoint,
    required MapConfiguration mapConfiguration,
    required String searchAssetPath,
    required String photonUrl,
    List<MapTileProvider>? mapTileProviders,
  }) {
    return [
      BlocProvider<RouteTransportsCubit>(
        create: (context) => RouteTransportsCubit(otpGraphqlEndpoint),
      ),
      BlocProvider<SearchLocationsCubit>(
        create: (context) => SearchLocationsCubit(
          searchLocationRepository: DefaultSearchLocation(
            searchAssetPath,
            photonUrl,
          ),
        ),
      ),
      BlocProvider<MapRouteCubit>(
        create: (context) => MapRouteCubit(otpEndpoint),
      ),
      BlocProvider<MapRouteCubit>(
        create: (context) => MapRouteCubit(otpEndpoint),
      ),
      BlocProvider<MapConfigurationCubit>(
        create: (context) => MapConfigurationCubit(mapConfiguration),
      ),
      BlocProvider<MapTileProviderCubit>(
        create: (context) => MapTileProviderCubit(
          mapTileProviders: mapTileProviders ?? [OSMDefaultMapTile()],
        ),
      ),
    ];
  }

  static RouterDelegate<Object> routerDelegate({
    required String appName,
    required String cityName,
    required String countryName,
    WidgetBuilder? backgroundImageBuilder,
    AsyncExecutor? asyncExecutor,
    required String urlShareApp,
    required String urlFeedback,
    required String emailContact,
    UrlSocialMedia? urlSocialMedia,
  }) {
    generateDrawer(String currentRoute) {
      return (BuildContext _) => TrufiDrawer(
            currentRoute,
            appName: appName,
            countryName: countryName,
            cityName: cityName,
            backgroundImageBuilder: backgroundImageBuilder,
            urlShareApp: urlShareApp,
            menuItems: defaultMenuItems(defaultUrls: urlSocialMedia),
          );
    }

    return RoutemasterDelegate(
      routesBuilder: (routeContext) {
        return RouteMap(
          onUnknownRoute: (_) => const Redirect(HomePage.route),
          routes: {
            HomePage.route: (route) => NoAnimationPage(
                  child: HomePage(
                    asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                    mapBuilder: (
                      mapContext,
                      trufiMapController,
                    ) {
                      return TrufiMapRoute(
                        asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                        trufiMapController: trufiMapController,
                      );
                    },
                    drawerBuilder: generateDrawer(HomePage.route),
                  ),
                ),
            TransportList.route: (route) => NoAnimationPage(
                  child: TransportList(
                    drawerBuilder: generateDrawer(TransportList.route),
                  ),
                ),
            TransportListDetail.route: (route) => NoAnimationPage(
                  child: TransportListDetail(
                    id: Uri.decodeQueryComponent(route.pathParameters['id']!),
                  ),
                ),
            SavedPlacesPage.route: (route) => NoAnimationPage(
                  child: SavedPlacesPage(
                    drawerBuilder: generateDrawer(SavedPlacesPage.route),
                  ),
                ),
            FeedbackPage.route: (route) => NoAnimationPage(
                  child: FeedbackPage(
                    urlFeedback: urlFeedback,
                    drawerBuilder: generateDrawer(FeedbackPage.route),
                  ),
                ),
            AboutPage.route: (route) => NoAnimationPage(
                  child: AboutPage(
                    appName: appName,
                    cityName: cityName,
                    countryName: countryName,
                    emailContact: emailContact,
                    drawerBuilder: generateDrawer(AboutPage.route),
                  ),
                ),
          },
        );
      },
    );
  }
}
