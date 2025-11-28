import 'dart:async';

import '../../domain/entities/itinerary_leg.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/repositories/map_route_repository.dart';
import '../../domain/services/routing_service.dart';
import 'routing_map_layer.dart';

/// Controller for managing routing on the map.
///
/// This controller handles:
/// - Origin and destination management
/// - Route fetching via [RoutingService]
/// - Caching via [MapRouteRepository]
/// - Map layer updates
class RoutingMapController extends RoutingMapLayer {
  RoutingMapController(
    super.controller, {
    required RoutingService routingService,
    required MapRouteRepository cacheRepository,
    required super.transportIconBuilder,
    super.layerLevel = 2,
  })  : _routingService = routingService,
        _cacheRepository = cacheRepository {
    _initFromCache();
  }

  final RoutingService _routingService;
  final MapRouteRepository _cacheRepository;

  Future<void> _initFromCache() async {
    await _cacheRepository.loadRepository();

    final results = await Future.wait([
      _cacheRepository.getOriginPosition(),
      _cacheRepository.getDestinationPosition(),
      _cacheRepository.getPlan(),
    ]);

    final cachedOrigin = results[0] as RoutingLocation?;
    final cachedDestination = results[1] as RoutingLocation?;
    final cachedPlan = results[2] as Plan?;

    if (cachedOrigin != null) setOrigin(cachedOrigin);
    if (cachedDestination != null) setDestination(cachedDestination);
    if (cachedPlan != null) setPlan(cachedPlan);
  }

  /// Adds an origin location.
  Future<void> addOrigin(RoutingLocation location) async {
    setOrigin(location);
    unawaited(_cacheRepository.saveOriginPosition(location));
  }

  /// Adds a destination location.
  Future<void> addDestination(RoutingLocation location) async {
    setDestination(location);
    unawaited(_cacheRepository.saveDestinationPosition(location));
  }

  /// Fetches a plan from origin to destination.
  ///
  /// [onMarkersReady] is called when markers need to be prepared (e.g., for image generation).
  Future<Plan?> fetchPlan({
    String? locale,
    Future<void> Function(List<ItineraryLeg> legs)? onMarkersReady,
  }) async {
    if (origin == null || destination == null) return null;

    final routingPlan = await _routingService.fetchPlan(
      from: origin!,
      to: destination!,
      locale: locale,
      filterWalkOnly: true,
    );

    // Notify about markers that need preparation
    if (onMarkersReady != null && routingPlan.itineraries != null) {
      final legs = routingPlan.itineraries!.expand((i) => i.legs).toList();
      await onMarkersReady(legs);
    }

    setPlan(routingPlan);
    unawaited(_cacheRepository.savePlan(routingPlan));

    return routingPlan;
  }

  /// Clears all routing data including cache.
  void clearAll() {
    clear();
    unawaited(_cacheRepository.saveOriginPosition(null));
    unawaited(_cacheRepository.saveDestinationPosition(null));
    unawaited(_cacheRepository.savePlan(null));
  }
}
