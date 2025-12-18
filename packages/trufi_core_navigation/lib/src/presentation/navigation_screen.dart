import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../cubit/navigation_cubit.dart';
import '../models/navigation_config.dart';
import '../models/navigation_state.dart';
import '../utils/itinerary_converter.dart';
import 'layers/navigation_layer.dart';
import 'widgets/navigation_bottom_panel.dart';

/// Factory function to create a NavigationLayer with a controller.
typedef NavigationLayerFactory = NavigationLayer Function(
    TrufiMapController controller);

/// Screen for turn-by-turn navigation.
class NavigationScreen extends StatefulWidget {
  /// The route to navigate.
  final NavigationRoute route;

  /// Builder for the map widget.
  ///
  /// The [layerFactory] should be called with the map controller to create
  /// the navigation layer. The returned layer will be managed by this screen.
  ///
  /// Example:
  /// ```dart
  /// mapBuilder: (context, layerFactory, userPosition, followUser) {
  ///   return TrufiMap(
  ///     controller: mapController,
  ///     onMapReady: () {
  ///       final navLayer = layerFactory(mapController);
  ///       // navLayer is now registered and will be updated automatically
  ///     },
  ///   );
  /// }
  /// ```
  final Widget Function(
    BuildContext context,
    NavigationLayerFactory layerFactory,
    NavigationState state,
  ) mapBuilder;

  /// Location service to use for tracking.
  final LocationService locationService;

  /// Optional navigation configuration.
  final NavigationConfig config;

  /// Mode icon widget for the transport.
  final Widget? modeIcon;

  const NavigationScreen({
    super.key,
    required this.route,
    required this.mapBuilder,
    required this.locationService,
    this.config = const NavigationConfig(),
    this.modeIcon,
  });

  /// Show the navigation screen.
  static Future<void> show(
    BuildContext context, {
    required NavigationRoute route,
    required Widget Function(
      BuildContext context,
      NavigationLayerFactory layerFactory,
      NavigationState state,
    ) mapBuilder,
    required LocationService locationService,
    NavigationConfig config = const NavigationConfig(),
    Widget? modeIcon,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NavigationScreen(
          route: route,
          mapBuilder: mapBuilder,
          locationService: locationService,
          config: config,
          modeIcon: modeIcon,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Show the navigation screen from an OTP itinerary.
  ///
  /// This is a convenience method that converts the itinerary to a
  /// NavigationRoute and shows the navigation screen.
  ///
  /// [mapEngineManager] is used to build the map widget.
  /// The initial map center uses current location or falls back to route origin.
  static Future<void> showFromItinerary(
    BuildContext context, {
    required routing.Itinerary itinerary,
    required LocationService locationService,
    required MapEngineManager mapEngineManager,
    NavigationConfig config = const NavigationConfig(),
    Widget? modeIcon,
  }) {
    final route = ItineraryConverter.toNavigationRoute(itinerary);

    // Get current location or use route origin as fallback
    final currentLocation = locationService.currentLocation;
    final fallbackCenter = route.geometry.isNotEmpty
        ? route.geometry.first
        : const LatLng(0, 0);

    return show(
      context,
      route: route,
      locationService: locationService,
      config: config,
      modeIcon: modeIcon,
      mapBuilder: (ctx, layerFactory, state) {
        final controller = TrufiMapController(
          initialCameraPosition: TrufiCameraPosition(
            target: currentLocation != null
                ? LatLng(
                    currentLocation.latitude,
                    currentLocation.longitude,
                  )
                : fallbackCenter,
            zoom: 16,
          ),
        );

        // Create navigation layer
        layerFactory(controller);

        return mapEngineManager.currentEngine.buildMap(
          controller: controller,
          isDarkMode: Theme.of(ctx).brightness == Brightness.dark,
        );
      },
    );
  }

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with WidgetsBindingObserver {
  late final NavigationCubit _cubit;
  NavigationLayer? _navigationLayer;
  Widget? _mapWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Keep screen awake during navigation
    if (widget.config.keepScreenOn) {
      WakelockPlus.enable();
    }

    // Initialize cubit
    _cubit = NavigationCubit(
      locationService: widget.locationService,
      config: widget.config,
    );

    // Start navigation
    _cubit.startNavigation(widget.route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build map widget once after dependencies are available
    _mapWidget ??= widget.mapBuilder(
      context,
      _createNavigationLayer,
      _cubit.state,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Disable wakelock
    WakelockPlus.disable();

    // Clean up
    _cubit.stopNavigation();
    _cubit.close();
    _navigationLayer?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cubit.setBackgroundMode(true);
    } else if (state == AppLifecycleState.resumed) {
      _cubit.setBackgroundMode(false);
    }
  }

  NavigationLayer _createNavigationLayer(TrufiMapController controller) {
    _navigationLayer?.dispose();
    _navigationLayer = NavigationLayer(controller);

    // Apply current state immediately
    _navigationLayer!.updateNavigation(_cubit.state);

    return _navigationLayer!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<NavigationCubit, NavigationState>(
        listener: (context, state) {
          // Update navigation layer when state changes
          _navigationLayer?.updateNavigation(state);
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                // Map (built once and cached)
                if (_mapWidget != null)
                  Positioned.fill(
                    child: _mapWidget!,
                  ),

                // Bottom panel
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPanel(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, NavigationState state) {
    switch (state.status) {
      case NavigationStatus.idle:
      case NavigationStatus.initializing:
        return _buildLoadingPanel(context);

      case NavigationStatus.navigating:
      case NavigationStatus.paused:
        return NavigationBottomPanel(
          state: state,
          onExitNavigation: () => _exitNavigation(context),
        );

      case NavigationStatus.completed:
        return NavigationCompletedPanel(
          destinationName: state.destinationStop?.name,
          onClose: () => Navigator.of(context).pop(),
        );

      case NavigationStatus.error:
        return NavigationErrorPanel(
          errorMessage: state.errorMessage ?? 'An error occurred',
          onRetry: () => _cubit.startNavigation(widget.route),
          onClose: () => Navigator.of(context).pop(),
          onOpenSettings: state.errorMessage?.contains('settings') == true
              ? () => widget.locationService.openAppSettings()
              : null,
        );
    }
  }

  Widget _buildLoadingPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Starting navigation...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Getting your location',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exitNavigation(BuildContext context) {
    _cubit.stopNavigation();
    Navigator.of(context).pop();
  }
}
