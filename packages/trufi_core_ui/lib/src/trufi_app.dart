import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'l10n/core_localizations.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';

export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show AppConfiguration, TrufiScreen, ScreenMenuItem, ScreenThemeData, TrufiLocaleConfig, TrufiThemeConfig, SocialMediaLink;
export 'services/deep_link_service.dart' show SharedRoute, SharedRouteNotifier;

/// Run the Trufi app with the given configuration
Future<void> runTrufiApp(AppConfiguration config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all screen modules
  for (final screen in config.screens) {
    await screen.initialize();
  }

  // Run the app
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

  @override
  void initState() {
    super.initState();
    _localeManager = LocaleManager(
      defaultLocale: widget.config.localeConfig.defaultLocale,
    );
    _themeManager = ThemeManager(
      defaultThemeMode: widget.config.themeConfig.themeMode,
    );
    _router = AppRouter(
      screens: widget.config.screens,
      socialMediaLinks: widget.config.socialMediaLinks,
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
    final defaultTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );

    final defaultDarkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );

    final screenDelegates = widget.config.screens.expand((s) => s.localizationsDelegates).toList();
    final screenProviders = widget.config.screens.expand((s) => s.providers).toList();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _localeManager),
        ChangeNotifierProvider.value(value: _themeManager),
        ChangeNotifierProvider.value(value: _sharedRouteNotifier),
        ...widget.config.providers,
        ...screenProviders,
      ],
      child: _TrufiMaterialApp(
        config: widget.config,
        router: _router,
        defaultTheme: defaultTheme,
        defaultDarkTheme: defaultDarkTheme,
        screenDelegates: screenDelegates,
      ),
    );
  }
}

class _TrufiMaterialApp extends StatelessWidget {
  final AppConfiguration config;
  final AppRouter router;
  final ThemeData defaultTheme;
  final ThemeData defaultDarkTheme;
  final List<LocalizationsDelegate> screenDelegates;

  const _TrufiMaterialApp({
    required this.config,
    required this.router,
    required this.defaultTheme,
    required this.defaultDarkTheme,
    required this.screenDelegates,
  });

  @override
  Widget build(BuildContext context) {
    final localeManager = LocaleManager.watch(context);
    final themeManager = ThemeManager.watch(context);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: config.themeConfig.theme ?? defaultTheme,
      darkTheme: config.themeConfig.darkTheme ?? defaultDarkTheme,
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
    );
  }
}
