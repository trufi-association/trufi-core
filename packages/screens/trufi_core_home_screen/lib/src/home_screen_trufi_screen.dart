import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../l10n/home_screen_localizations.dart';
import 'config/home_screen_config.dart';
import 'cubit/route_planner_cubit.dart';
import 'repository/home_screen_repository.dart';
import 'repository/home_screen_repository_impl.dart';
import 'services/request_plan_service.dart';
import 'services/routing_engine_request_plan_service.dart';
import 'services/routing_request_plan_service.dart';
import 'widgets/home_screen.dart';

/// Home screen module for TrufiApp integration.
class HomeScreenTrufiScreen extends TrufiScreen {
  final HomeScreenConfig config;
  late final HomeScreenRepository _repository;
  late final routing.RoutingPreferencesManager _routingPreferencesManager;

  /// Callback when itinerary details are requested.
  final void Function(routing.Itinerary itinerary)? onItineraryDetails;

  /// Callback when navigation is started for an itinerary.
  /// Receives the BuildContext, itinerary, and LocationService so the caller
  /// can show the navigation screen using the same location service.
  final void Function(
    BuildContext context,
    routing.Itinerary itinerary,
    LocationService locationService,
  )? onStartNavigation;

  /// Static initialization for the module.
  /// Call this once at app startup before using any HomeScreen functionality.
  static Future<void> init() async {
    // No initialization needed for SharedPreferences
  }

  HomeScreenTrufiScreen({
    required this.config,
    HomeScreenRepository? repository,
    this.onItineraryDetails,
    this.onStartNavigation,
  }) {
    _repository = repository ?? HomeScreenRepositoryImpl();
    _routingPreferencesManager = routing.RoutingPreferencesManager();
  }

  /// Creates the appropriate request service based on available context.
  RequestPlanService _createRequestService(BuildContext context) {
    // Prefer RoutingEngineManager if available (new pattern)
    final routingEngineManager = routing.RoutingEngineManager.maybeRead(context);
    if (routingEngineManager != null) {
      return RoutingEngineRequestPlanService(manager: routingEngineManager);
    }

    // Fall back to legacy OtpConfiguration
    if (config.otpConfiguration != null) {
      return RoutingRequestPlanService(config.otpConfiguration!);
    }

    throw StateError(
      'No routing configuration available. '
      'Either provide RoutingEngineManager in providers or set otpConfiguration in HomeScreenConfig.',
    );
  }

  @override
  String get id => 'home';

  @override
  String get path => '/';

  @override
  Widget Function(BuildContext context) get builder => (context) {
    return HomeScreen(
      onMenuPressed: () {
        Scaffold.of(context).openDrawer();
      },
      config: config,
      onItineraryDetails: onItineraryDetails,
      onStartNavigation: onStartNavigation,
    );
  };

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...HomeScreenLocalizations.localizationsDelegates,
    // Include POI layers localizations if POI layers are configured
    if (config.poiLayersManager != null) POILayersLocalizations.delegate,
  ];

  @override
  List<Locale> get supportedLocales => HomeScreenLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<routing.RoutingPreferencesManager>.value(
      value: _routingPreferencesManager,
    ),
    BlocProvider<RoutePlannerCubit>(
      create: (context) => RoutePlannerCubit(
        repository: _repository,
        requestService: _createRequestService(context),
        getRoutingPreferences: () => _routingPreferencesManager.preferences,
      )..initialize(),
    ),
    if (config.poiLayersManager != null)
      ChangeNotifierProvider<POILayersManager>.value(
        value: config.poiLayersManager!,
      ),
  ];

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.home, order: 0);

  @override
  bool get hasOwnAppBar => true; // Home usa SearchLocationBar como su AppBar

  @override
  String getLocalizedTitle(BuildContext context) {
    return HomeScreenLocalizations.of(context).menuHome;
  }

  @override
  Future<void> initialize() async {
    await _repository.initialize();
    await _routingPreferencesManager.initialize();

    // Initialize POI layers if available (optional dependency)
    // This requires POILayersCubit to be provided in AppConfiguration.providers
    // The cubit will be accessed via context during the first build
  }

  @override
  Future<void> dispose() async {
    await _repository.dispose();
  }
}
