import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart' show MapEngineManager;
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show RoutingEngineManager;
import 'package:trufi_core_utils/trufi_core_utils.dart' show OverlayManager;

import 'default_init_screen.dart';

/// Widget that initializes screens and managers before showing the app.
///
/// This widget handles the app initialization phase by:
/// 1. Initializing all app managers (OnboardingManager, etc.)
/// 2. Initializing all screen modules (each screen is responsible for initializing its own providers)
/// 3. Showing a loading screen during initialization
/// 4. Showing an error screen with retry if initialization fails
/// 5. Showing the child widget once initialization completes
///
/// Customize the initialization UI via [screenBuilder].
/// Customize the theme via [theme].
class AppInitializer extends StatefulWidget {
  final List<TrufiScreen> screens;
  final AppInitScreenBuilder? screenBuilder;
  final Widget child;

  /// Optional theme for the initialization screen.
  /// Defaults to a green Material 3 theme.
  final ThemeData? theme;

  const AppInitializer({
    super.key,
    required this.screens,
    this.screenBuilder,
    required this.child,
    this.theme,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  AppInitStep? _currentStep;

  @override
  void initState() {
    super.initState();
    // Start initialization after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _currentStep = AppInitStep.starting;
    });

    try {
      await _performInitialization();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Notify app is ready AFTER the UI is built so overlays can be shown
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            OverlayManager.read(context).notifyAppReady();
          }
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

  void _setStep(AppInitStep step) {
    if (mounted) {
      setState(() => _currentStep = step);
    }
  }

  /// Performs the actual initialization of managers and screens.
  Future<void> _performInitialization() async {
    // Capture all managers before async operations to avoid BuildContext issues
    final overlayManager = OverlayManager.read(context);
    final mapManager = MapEngineManager.read(context);
    final routingManager = RoutingEngineManager.read(context);

    _setStep(AppInitStep.initializingOverlays);
    await overlayManager.initializeManagers();

    _setStep(AppInitStep.loadingMaps);
    await mapManager.initializeEngines();

    _setStep(AppInitStep.loadingRoutes);
    await routingManager.initializeEngines();

    // Initialize all screen modules
    _setStep(AppInitStep.preparingScreens);
    for (final screen in widget.screens) {
      await screen.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the actual app once initialized
    if (_isInitialized) {
      return widget.child;
    }

    // Use custom builder or default to DefaultInitScreen
    final builder =
        widget.screenBuilder ??
        (context, step, error, retry) => DefaultInitScreen(
          currentStep: step,
          errorMessage: error,
          onRetry: retry,
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.theme,
      home: builder(
        context,
        _hasError ? null : _currentStep,
        _errorMessage,
        _initialize,
      ),
    );
  }
}
