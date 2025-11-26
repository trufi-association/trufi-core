import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tr_translations/tr_translations.dart';
import 'package:trufi_core/default_theme.dart';
import 'package:trufi_core/language_provider.dart';
import 'package:trufi_core/pages/about/about.dart';
import 'package:trufi_core/pages/feedback/feedback.dart';
import 'package:trufi_core/pages/home/widgets/app_drawer.dart';
import 'package:trufi_core/pages/saved_places/saved_places.dart';
import 'package:trufi_core/pages/tickets/tickets_page.dart';
import 'package:trufi_core/screens/route_navigation/route_navigation.dart';

/// Main Trufi App widget with GoRouter configuration
class TrufiApp extends StatelessWidget {
  const TrufiApp({
    super.key,
    this.title = 'Trufi App',
    this.appName = 'Trufi Transit',
    this.cityName,
    this.urlRepository = 'https://github.com/trufi-association/trufi_core',
    this.urlFeedback = 'https://www.trufi-association.org/',
    this.exploreFaresUrl,
    this.drawer,
    this.customRouterConfig,
    this.supportedLocales = AppLocalizations.supportedLocales,
    this.showTicketsInDrawer = true,
    this.drawerHeaderImageUrl,
    this.drawerLogoUrl,
    this.localizationsConfig,
  });

  final String title;
  final String appName;
  final String? cityName;
  final String urlRepository;
  final String urlFeedback;
  final String? exploreFaresUrl;
  final Widget? drawer;
  final GoRouter? customRouterConfig;
  final List<Locale> supportedLocales;
  final bool showTicketsInDrawer;
  final String? drawerHeaderImageUrl;
  final String? drawerLogoUrl;
  final TrufiLocalizationsConfig? localizationsConfig;

  @override
  Widget build(BuildContext context) {
    final router = customRouterConfig ?? _buildDefaultRouter();

    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        title: title,
        supportedLocales: supportedLocales,
        theme: lightTheme,
        darkTheme: darkTheme,
        builder: (context, child) => TrufiLocalizationsProvider(
          localizations: TrufiLocalizations(
            AppLocalizations.of(context),
            localizationsConfig,
          ),
          child: child!,
        ),
      ),
    );
  }

  GoRouter _buildDefaultRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return Scaffold(
              drawer:
                  drawer ??
                  AppDrawer(
                    appName: appName,
                    showTickets: showTicketsInDrawer,
                    headerImageUrl:
                        drawerHeaderImageUrl ??
                        'https://www.trufi-association.org/wp-content/uploads/2021/11/Delhi-autorickshaw-CC-BY-NC-ND-ai_enlarged-tweaked-1800x1200px.jpg',
                    logoUrl:
                        drawerLogoUrl ??
                        'https://trufi.app/wp-content/uploads/2019/02/48.png',
                  ),
              body: const RouteNavigationScreen(),
            );
          },
          routes: [
            GoRoute(
              path: AboutPage.route,
              builder: (context, state) {
                return AboutPage(
                  appName: appName,
                  cityName: cityName ?? appName,
                  urlRepository: urlRepository,
                );
              },
            ),
            GoRoute(
              path: FeedbackPage.route,
              builder: (context, state) {
                return FeedbackPage(
                  urlFeedback: urlFeedback,
                );
              },
            ),
            GoRoute(
              path: SavedPlacesPage.route,
              builder: (context, state) {
                return const SavedPlacesPage();
              },
            ),
            GoRoute(
              path: TicketsPage.route,
              builder: (context, state) {
                return TicketsPage(
                  exploreFaresUrl: exploreFaresUrl,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
