import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'l10n/core_localizations.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';

export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show
        AppConfiguration,
        TrufiScreen,
        ScreenMenuItem,
        ScreenThemeData,
        TrufiLocaleConfig,
        TrufiThemeConfig,
        SocialMediaLink,
        AppInitializerBuilder,
        LoadingScreenBuilder,
        ErrorScreenBuilder;
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
      defaultLocale: widget.config.localeConfig.defaultLocale,
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
      // Layer 2: Initialize screens and providers with loading screen
      child: AppInitializer(
        screens: widget.config.screens,
        providers: widget.config.providers,
        loadingScreenBuilder: widget.config.loadingScreenBuilder,
        errorScreenBuilder: widget.config.errorScreenBuilder,
        customBuilder: widget.config.appInitializerBuilder,
        // Layer 3: Show the actual app once initialized
        child: _TrufiMaterialApp(
          config: widget.config,
          router: _router,
          defaultTheme: defaultTheme,
          defaultDarkTheme: defaultDarkTheme,
          screenDelegates: screenDelegates,
        ),
      ),
    );
  }
}

/// Widget that initializes screens before showing the app.
///
/// This widget handles the app initialization phase by:
/// 1. Initializing all screen modules (each screen is responsible for initializing its own providers)
/// 2. Showing a loading screen during initialization
/// 3. Showing an error screen with retry if initialization fails
/// 4. Showing the child widget once initialization completes
///
/// You can customize the UI via [loadingScreenBuilder], [errorScreenBuilder],
/// or completely override the flow with [customBuilder].
class AppInitializer extends StatefulWidget {
  final List<TrufiScreen> screens;
  final List<SingleChildWidget> providers;
  final LoadingScreenBuilder? loadingScreenBuilder;
  final ErrorScreenBuilder? errorScreenBuilder;
  final AppInitializerBuilder? customBuilder;
  final Widget child;

  const AppInitializer({
    super.key,
    required this.screens,
    required this.providers,
    this.loadingScreenBuilder,
    this.errorScreenBuilder,
    this.customBuilder,
    required this.child,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await _performInitialization();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error during initialization: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If custom builder is provided, use it
    if (widget.customBuilder != null) {
      return widget.customBuilder!(
        context,
        _performInitialization,
        widget.child,
      );
    }

    // Otherwise, use default initialization UI
    return _buildDefaultInitializer();
  }

  /// Performs the actual initialization of screens.
  /// This can be called by custom builders.
  ///
  /// Each screen's initialize() method should initialize any providers it needs.
  Future<void> _performInitialization() async {
    // Initialize all screen modules
    // Each screen is responsible for initializing its own providers
    for (final screen in widget.screens) {
      await screen.initialize();
    }
  }

  Widget _buildDefaultInitializer() {
    // Show error screen with retry
    if (_hasError) {
      // Use custom error screen builder if provided
      if (widget.errorScreenBuilder != null) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: widget.errorScreenBuilder!(
            context,
            _errorMessage ?? 'Unknown error',
            _initialize,
          ),
        );
      }

      // Default error screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _initialize,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show loading screen
    if (!_isInitialized) {
      // Use custom loading screen builder if provided
      if (widget.loadingScreenBuilder != null) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: widget.loadingScreenBuilder!(context),
        );
      }

      // Default loading screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show the actual app
    return widget.child;
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
