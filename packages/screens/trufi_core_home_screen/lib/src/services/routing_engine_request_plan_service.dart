import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'request_plan_service.dart';

/// A RequestPlanService that uses RoutingEngineManager to route.
///
/// This service gets the current engine from the manager and uses it
/// to create the plan repository for routing requests.
class RoutingEngineRequestPlanService implements RequestPlanService {
  final routing.RoutingEngineManager _manager;

  /// Cached repositories by provider ID.
  final Map<String, routing.PlanRepository> _repositories = {};

  RoutingEngineRequestPlanService({
    required routing.RoutingEngineManager manager,
  }) : _manager = manager;

  /// Gets or creates a repository for the current engine.
  routing.PlanRepository _getRepository() {
    final engine = _manager.currentEngine;
    return _repositories.putIfAbsent(
      engine.id,
      () => engine.createPlanRepository(),
    );
  }

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    List<routing.TransportMode>? transportModes,
    String? locale,
    DateTime? dateTime,
    routing.RoutingPreferences? preferences,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final engine = _manager.currentEngine;

    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 ROUTING REQUEST STARTED');
    debugPrint('║ Engine: ${engine.id} (${engine.requiresInternet ? "online" : "offline"})');
    debugPrint('║ From: ${from.description} (${from.latitude}, ${from.longitude})');
    debugPrint('║ To: ${to.description} (${to.latitude}, ${to.longitude})');
    debugPrint('╠══════════════════════════════════════════════════════════════');

    final effectiveDateTime = _getEffectiveDateTime(preferences, dateTime);
    final arriveBy = preferences?.timeMode == routing.TimeMode.arriveBy;

    final routingFrom = routing.RoutingLocation(
      position: LatLng(from.latitude, from.longitude),
      description: from.description,
    );
    final routingTo = routing.RoutingLocation(
      position: LatLng(to.latitude, to.longitude),
      description: to.description,
    );

    try {
      final repository = _getRepository();

      final plan = await repository.fetchPlan(
        from: routingFrom,
        to: routingTo,
        locale: locale,
        dateTime: effectiveDateTime,
        arriveBy: arriveBy,
        preferences: preferences,
      );

      totalStopwatch.stop();
      _logSuccess(plan, totalStopwatch.elapsedMilliseconds);

      // Sort itineraries
      if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
        final sortedItineraries = List<routing.Itinerary>.from(plan.itineraries!);
        sortedItineraries.sort((a, b) {
          final weightA = _calculateWeight(a);
          final weightB = _calculateWeight(b);
          return weightA.compareTo(weightB);
        });
        return plan.copyWith(itineraries: sortedItineraries);
      }

      return plan;
    } catch (e) {
      totalStopwatch.stop();
      debugPrint('║ ❌ REQUEST FAILED: $e');
      debugPrint('║ Total time: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  void _logSuccess(routing.Plan plan, int totalMs) {
    final count = plan.itineraries?.length ?? 0;
    debugPrint('╠══════════════════════════════════════════════════════════════');
    debugPrint('║ ✅ REQUEST SUCCESSFUL');
    debugPrint('║ Itineraries found: $count');
    debugPrint('║ Total time: ${totalMs}ms');
    if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
      for (var i = 0; i < plan.itineraries!.length; i++) {
        final it = plan.itineraries![i];
        final durationMin = it.duration.inMinutes;
        final walkMin = it.walkTime.inMinutes;
        debugPrint('║   [$i] ${durationMin}min total, ${walkMin}min walk, ${it.numberOfTransfers} transfers');
      }
    }
    debugPrint('╚══════════════════════════════════════════════════════════════');
  }

  double _calculateWeight(routing.Itinerary itinerary) {
    return (itinerary.numberOfTransfers * 0.65) +
        (itinerary.walkDistance * 0.3) +
        ((itinerary.distance / 100) * 0.05);
  }

  DateTime _getEffectiveDateTime(
    routing.RoutingPreferences? preferences,
    DateTime? fallback,
  ) {
    if (preferences == null) return fallback ?? DateTime.now();

    if (preferences.timeMode == routing.TimeMode.leaveNow) {
      return DateTime.now();
    }

    return preferences.dateTime ?? fallback ?? DateTime.now();
  }
}
