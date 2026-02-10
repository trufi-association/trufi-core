import '../../domain/entities/routing_capabilities.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/transit_route_repository.dart';
import '../routing_provider.dart';
import 'data/trufi_planner_plan_repository.dart';
import 'data/trufi_planner_transit_route_repository.dart';
import 'trufi_planner_config.dart';
import 'trufi_planner_data_source.dart';

/// Routing provider using TrufiPlanner.
///
/// Supports two modes:
/// - **Local** (mobile): Loads GTFS ZIP from Flutter assets for offline routing
/// - **Remote** (web): Calls trufi-server-planner HTTP API for online routing
///
/// Example (mobile):
/// ```dart
/// TrufiPlannerProvider(
///   config: TrufiPlannerConfig.local(
///     gtfsAsset: 'assets/routing/gtfs.zip',
///   ),
/// )
/// ```
///
/// Example (web):
/// ```dart
/// TrufiPlannerProvider(
///   config: TrufiPlannerConfig.remote(
///     serverUrl: 'https://planner.trufi.dev',
///   ),
/// )
/// ```
class TrufiPlannerProvider implements IRoutingProvider {
  final TrufiPlannerConfig config;
  late final TrufiPlannerDataSource _dataSource;

  TrufiPlannerPlanRepository? _planRepository;
  TrufiPlannerTransitRouteRepository? _transitRouteRepository;

  TrufiPlannerProvider({required this.config})
      : _dataSource = TrufiPlannerDataSource(config: config);

  @override
  String get id => config.providerId ?? 'trufi_planner';

  @override
  String get name =>
      config.displayName ??
      (config.isLocal ? 'Offline (GTFS)' : 'Online (Planner)');

  @override
  String get description =>
      config.description ??
      (config.isLocal
          ? 'Routing sin conexión usando datos GTFS'
          : 'Routing en línea usando Trufi Planner');

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => config.isRemote;

  @override
  RoutingCapabilities get capabilities => RoutingCapabilities.gtfsOffline;

  /// Whether data is loaded and ready.
  bool get isLoaded => _dataSource.isLoaded;

  /// Whether data is currently loading.
  bool get isLoading => _dataSource.isLoading;

  /// Status of the data source.
  TrufiPlannerDataStatus get status => _dataSource.status;

  /// Error message if loading failed.
  String? get errorMessage => _dataSource.errorMessage;

  @override
  Future<void> initialize() => _dataSource.preload();

  /// Access to the underlying data source for advanced queries.
  TrufiPlannerDataSource get dataSource => _dataSource;

  @override
  PlanRepository createPlanRepository() {
    _planRepository ??= TrufiPlannerPlanRepository(dataSource: _dataSource);
    return _planRepository!;
  }

  @override
  TransitRouteRepository? createTransitRouteRepository() {
    _transitRouteRepository ??=
        TrufiPlannerTransitRouteRepository(dataSource: _dataSource);
    return _transitRouteRepository;
  }

  /// Clear all loaded data from memory.
  void clear() {
    _dataSource.clear();
    _planRepository = null;
    _transitRouteRepository = null;
  }
}
