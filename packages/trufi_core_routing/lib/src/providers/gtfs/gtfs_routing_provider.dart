import '../../domain/entities/routing_capabilities.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/transit_route_repository.dart';
import '../routing_provider.dart';
import 'data/gtfs_plan_repository.dart';
import 'data/gtfs_transit_route_repository.dart';
import 'gtfs_data_source.dart';
import 'gtfs_routing_config.dart';

/// Routing provider for offline routing using GTFS data.
///
/// This provider uses a GTFS ZIP file to perform route planning without
/// an internet connection. It supports:
/// - Direct routes (single transit leg)
/// - Transfer routes (multiple transit legs)
/// - Schedule-based departures (when frequencies.txt or stop_times.txt available)
/// - Route shapes (when shapes.txt available)
///
/// Example:
/// ```dart
/// final provider = GtfsRoutingProvider(
///   config: GtfsRoutingConfig(
///     gtfsAsset: 'assets/routing/gtfs.zip',
///     displayName: 'Offline (GTFS)',
///   ),
/// );
///
/// // Preload data at app startup (recommended)
/// await provider.preload();
///
/// // Get plan repository for route queries
/// final repository = provider.createPlanRepository();
/// ```
class GtfsRoutingProvider implements IRoutingProvider {
  /// Configuration for GTFS routing data.
  final GtfsRoutingConfig config;

  /// Shared data source (loaded once, used by all repositories).
  late final GtfsDataSource _dataSource;

  /// Cached plan repository.
  GtfsPlanRepository? _planRepository;

  /// Cached transit route repository.
  GtfsTransitRouteRepository? _transitRouteRepository;

  GtfsRoutingProvider({required this.config})
      : _dataSource = GtfsDataSource(assetPath: config.gtfsAsset);

  @override
  String get id => config.providerId ?? 'gtfs';

  @override
  String get name => config.displayName ?? 'Offline (GTFS)';

  @override
  String get description =>
      config.description ?? 'Routing sin conexión usando datos GTFS';

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => false;

  @override
  RoutingCapabilities get capabilities => RoutingCapabilities.gtfsOffline;

  /// Whether the GTFS data is loaded and ready.
  bool get isLoaded => _dataSource.isLoaded;

  /// Whether the GTFS data is currently loading.
  bool get isLoading => _dataSource.isLoading;

  /// Status of the GTFS data source.
  GtfsDataStatus get status => _dataSource.status;

  /// Error message if loading failed.
  String? get errorMessage => _dataSource.errorMessage;

  @override
  Future<void> initialize() => _dataSource.preload();

  /// Preload GTFS data.
  ///
  /// Call this at app startup to ensure data is available for routing.
  /// The data is parsed and indexed in memory for fast queries.
  @Deprecated('Use initialize() instead')
  Future<void> preload() => initialize();

  /// Access to the underlying data source for advanced queries.
  GtfsDataSource get dataSource => _dataSource;

  @override
  PlanRepository createPlanRepository() {
    _planRepository ??= GtfsPlanRepository(dataSource: _dataSource);
    return _planRepository!;
  }

  @override
  TransitRouteRepository? createTransitRouteRepository() {
    _transitRouteRepository ??=
        GtfsTransitRouteRepository(dataSource: _dataSource);
    return _transitRouteRepository;
  }

  /// Clear all loaded data from memory.
  void clear() {
    _dataSource.clear();
    _planRepository = null;
    _transitRouteRepository = null;
  }
}
