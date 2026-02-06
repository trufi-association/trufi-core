import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'app_initializer/app_initializer.dart';
import 'l10n/core_localizations.dart';
import 'overlay/overlay_container.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';

export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show
        AppConfiguration,
        AppOverlayManager,
        TrufiScreen,
        ScreenMenuItem,
        ScreenThemeData,
        TrufiLocaleConfig,
        TrufiThemeConfig,
        SocialMediaLink,
        AppInitStep,
        AppInitScreenBuilder;
export 'services/deep_link_service.dart' show SharedRoute, SharedRouteNotifier;

/// Run the Trufi app with the given configuration
Future<void> runTrufiApp(AppConfiguration config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Run the app (initialization happens inside TrufiApp)
  runApp(TrufiApp(config: config));
}

/// Main Trufi App widget
class TrufiApp extends StatefulWidget {
  final AppConfiguration config;

  const TrufiApp({super.key, required this.config});

  @override
  State<TrufiApp> createState() => _TrufiAppState();
}

class _TrufiAppState extends State<TrufiApp> {
  late final LocaleManager _localeManager;
  late final ThemeManager _themeManager;
  late final AppRouter _router;
  late final SharedRouteNotifier _sharedRouteNotifier;
  DeepLinkService? _deepLinkService;

  /// The initial route from the URL (captured before MaterialApp consumes it)
  String? _initialRoute;

  @override
  void initState() {
    super.initState();

    // Capture the initial route before it's lost during initialization
    if (kIsWeb) {
      _initialRoute =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (_initialRoute == '/' || _initialRoute == null) {
        _initialRoute = null; // Don't need to navigate if already at root
      }
    }

    _localeManager = LocaleManager(
      defaultLocale:
          widget.config.defaultLocale ?? widget.config.localeConfig.defaultLocale,
    );
    _themeManager = ThemeManager(
      defaultThemeMode: widget.config.themeConfig.themeMode,
    );
    _router = AppRouter(
      screens: widget.config.screens,
      socialMediaLinks: widget.config.socialMediaLinks,
      initialRoute: _initialRoute,
    );
    _sharedRouteNotifier = SharedRouteNotifier();

    // Initialize deep link service if scheme is configured
    if (widget.config.deepLinkScheme != null) {
      _deepLinkService = DeepLinkService(
        scheme: widget.config.deepLinkScheme,
        onRouteReceived: (route) {
          _sharedRouteNotifier.setPendingRoute(route);
        },
      );
      _deepLinkService!.initialize();
    }
  }

  @override
  void dispose() {
    _deepLinkService?.dispose();
    _sharedRouteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = widget.config.themeConfig;

    final screenDelegates = widget.config.screens
        .expand((s) => s.localizationsDelegates)
        .toList();
    final screenProviders = widget.config.screens
        .expand((s) => s.providers)
        .toList();

    // Layer 1: Inject all providers (without initializing yet)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _localeManager),
        ChangeNotifierProvider.value(value: _themeManager),
        ChangeNotifierProvider.value(value: _sharedRouteNotifier),
        ...widget.config.providers,
        ...screenProviders,
      ],
      // Layer 2: Initialize screens and managers with loading screen
      child: AppInitializer(
        screens: widget.config.screens,
        screenBuilder: widget.config.initScreenBuilder,
        theme: themeConfig.theme,
        // Layer 3: Show the actual app once initialized
        child: _TrufiMaterialApp(
          config: widget.config,
          router: _router,
          screenDelegates: screenDelegates,
        ),
      ),
    );
  }
}

class _TrufiMaterialApp extends StatelessWidget {
  final AppConfiguration config;
  final AppRouter router;
  final List<LocalizationsDelegate> screenDelegates;

  const _TrufiMaterialApp({
    required this.config,
    required this.router,
    required this.screenDelegates,
  });

  @override
  Widget build(BuildContext context) {
    final localeManager = LocaleManager.watch(context);
    final themeManager = ThemeManager.watch(context);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: config.themeConfig.theme,
      darkTheme: config.themeConfig.darkTheme,
      themeMode: themeManager.themeMode,
      routerConfig: router.router,
      locale: localeManager.currentLocale,
      supportedLocales: config.localeConfig.supportedLocales,
      localizationsDelegates: [
        CoreLocalizations.delegate,
        ...screenDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return OverlayContainer(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
