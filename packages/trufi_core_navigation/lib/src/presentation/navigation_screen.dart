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
import 'layers/navigation_layer.dart' as nav;
import 'widgets/navigation_bottom_panel.dart';

/// Screen for turn-by-turn navigation.
class NavigationScreen extends StatefulWidget {
  /// The route to navigate.
  final NavigationRoute route;

  /// Builder for the map widget.
  ///
  /// Receives the current navigation state and a list of layers
  /// (from NavigationLayer) to pass to TrufiMap.
  final Widget Function(
    BuildContext context,
    NavigationState state,
    List<TrufiLayer> navigationLayers,
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
      NavigationState state,
      List<TrufiLayer> navigationLayers,
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
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Show the navigation screen from an OTP itinerary.
  static Future<void> showFromItinerary(
    BuildContext context, {
    required routing.Itinerary itinerary,
    required LocationService locationService,
    required MapEngineManager mapEngineManager,
    NavigationConfig config = const NavigationConfig(),
    Widget? modeIcon,
  }) {
    final route = ItineraryConverter.toNavigationRoute(itinerary);
    final currentLocation = locationService.currentLocation;
    final fallbackCenter = route.geometry.isNotEmpty
        ? route.geometry.first
        : const LatLng(0, 0);

    final initialCamera = TrufiCameraPosition(
      target: currentLocation != null
          ? LatLng(currentLocation.latitude, currentLocation.longitude)
          : fallbackCenter,
      zoom: 16,
    );

    return show(
      context,
      route: route,
      locationService: locationService,
      config: config,
      modeIcon: modeIcon,
      mapBuilder: (ctx, state, navigationLayers) {
        return mapEngineManager.currentEngine.buildMap(
          initialCamera: initialCamera,
          layers: navigationLayers,
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
  late final nav.NavigationLayer _navLayerBuilder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.config.keepScreenOn) {
      WakelockPlus.enable();
    }

    _cubit = NavigationCubit(
      locationService: widget.locationService,
      config: widget.config,
    );

    _navLayerBuilder = nav.NavigationLayer();
    _cubit.startNavigation(widget.route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _cubit.stopNavigation();
    _cubit.close();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          // Build navigation layers from current state
          final layerData = _navLayerBuilder.buildLayerData(state);
          final navLayers = [
            TrufiLayer(
              id: nav.NavigationLayer.layerId,
              markers: layerData.markers,
              lines: layerData.lines,
            ),
          ];

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                // Map with declarative layers
                Positioned.fill(
                  child: widget.mapBuilder(context, state, navLayers),
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
