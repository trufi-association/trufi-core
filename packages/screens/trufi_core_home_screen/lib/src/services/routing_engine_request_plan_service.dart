import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'request_plan_service.dart';

/// A RequestPlanService that uses RoutingEngineManager to route.
///
/// This service delegates all routing requests to [RoutingEngineManager.fetchPlan],
/// which automatically uses the currently selected engine.
class RoutingEngineRequestPlanService implements RequestPlanService {
  final routing.RoutingEngineManager _manager;

  /// Optional OTP endpoint for fetching walk-only routes with real street
  /// geometry. When provided, a walk-only itinerary is requested from OTP
  /// and injected into the results for short-distance trips.
  final String? walkRouteEndpoint;

  RoutingEngineRequestPlanService({
    required routing.RoutingEngineManager manager,
    this.walkRouteEndpoint,
  }) : _manager = manager;

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final engine = _manager.currentEngine;

    debugPrint('');
    debugPrint(
      '╔══════════════════════════════════════════════════════════════',
    );
    debugPrint('║ ROUTING REQUEST STARTED');
    debugPrint(
      '║ Engine: ${engine.id} (${engine.requiresInternet ? "online" : "offline"})',
    );
    debugPrint(
      '║ From: ${from.description} (${from.latitude}, ${from.longitude})',
    );
    debugPrint('║ To: ${to.description} (${to.latitude}, ${to.longitude})');
    debugPrint(
      '╠══════════════════════════════════════════════════════════════',
    );

    final routingFrom = routing.RoutingLocation(
      position: LatLng(from.latitude, from.longitude),
      description: from.description,
    );
    final routingTo = routing.RoutingLocation(
      position: LatLng(to.latitude, to.longitude),
      description: to.description,
    );

    try {
      final plan = await _manager.fetchPlan(
        from: routingFrom,
        to: routingTo,
        locale: locale,
        dateTime: dateTime,
        arriveBy: arriveBy,
      );

      totalStopwatch.stop();
      _logSuccess(plan, totalStopwatch.elapsedMilliseconds);

      // Filter and sort itineraries
      if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
        // Remove itineraries with redundant same-line transfers
        // (e.g., Line 209 → Line 209), which are inefficient routing artifacts.
        final filtered = plan.itineraries!.where((itinerary) {
          return !_hasRedundantSameLineTransfer(itinerary);
        }).toList();

        final itineraries =
            filtered.isNotEmpty ? filtered : plan.itineraries!;

        // If no walk-only option exists and the distance is walkable,
        // fetch a real walking route from OTP so the user sees a
        // street-level path as an alternative.
        final hasWalkOnly = itineraries.any((it) => it.isWalkOnly);
        if (!hasWalkOnly) {
          final walkItinerary = await _fetchWalkItinerary(
            from: routingFrom,
            to: routingTo,
            dateTime: dateTime,
          );
          if (walkItinerary != null) {
            itineraries.add(walkItinerary);
          }
        }

        final sortedItineraries = List<routing.Itinerary>.from(itineraries);
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
      debugPrint('║ REQUEST FAILED: $e');
      debugPrint('║ Total time: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint(
        '╚══════════════════════════════════════════════════════════════',
      );
      rethrow;
    }
  }

  void _logSuccess(routing.Plan plan, int totalMs) {
    final count = plan.itineraries?.length ?? 0;
    debugPrint(
      '╠══════════════════════════════════════════════════════════════',
    );
    debugPrint('║ REQUEST SUCCESSFUL');
    debugPrint('║ Itineraries found: $count');
    debugPrint('║ Total time: ${totalMs}ms');
    if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
      for (var i = 0; i < plan.itineraries!.length; i++) {
        final it = plan.itineraries![i];
        final durationMin = it.duration.inMinutes;
        final walkMin = it.walkTime.inMinutes;
        debugPrint(
          '║   [$i] ${durationMin}min total, ${walkMin}min walk, ${it.numberOfTransfers} transfers',
        );
      }
    }
    debugPrint(
      '╚══════════════════════════════════════════════════════════════',
    );
  }

  /// Calculates a weight for sorting itineraries (lower = better).
  ///
  /// Priorities:
  /// 1. Fewer transfers (heavily penalized — each transfer adds significant cost)
  /// 2. Shorter total duration (the most practical measure of trip quality)
  /// 3. Less walking (secondary comfort factor)
  /// 4. Walk-only itineraries are preferred when they're short (under ~20 min)
  double _calculateWeight(routing.Itinerary itinerary) {
    final durationMin = itinerary.duration.inMinutes.toDouble();
    final transfers = itinerary.numberOfTransfers;
    final walkDistanceKm = itinerary.walkDistance / 1000;

    // Walk-only trips under 20 minutes are very attractive — give them a bonus
    if (itinerary.isWalkOnly && durationMin <= 20) {
      return durationMin * 0.5;
    }

    return (transfers * 15) + (durationMin * 1.0) + (walkDistanceKm * 3);
  }

  /// Fetches a walk-only itinerary from OTP with real street-level geometry.
  ///
  /// Returns null if:
  /// - No walk endpoint is configured
  /// - The distance is too far to walk (> ~2.5 km straight line)
  /// - The OTP request fails
  Future<routing.Itinerary?> _fetchWalkItinerary({
    required routing.RoutingLocation from,
    required routing.RoutingLocation to,
    required DateTime dateTime,
  }) async {
    if (walkRouteEndpoint == null) return null;

    // Only attempt walk routes for short distances (< 2.5 km straight line)
    const maxStraightLineMeters = 2500.0;
    final straightLine = const Distance().as(
      LengthUnit.Meter,
      from.position,
      to.position,
    );
    if (straightLine > maxStraightLineMeters) return null;

    try {
      final date =
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')}-'
          '${dateTime.year}';
      final time =
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';

      final uri = Uri.parse(
        '$walkRouteEndpoint/otp/routers/default/plan',
      ).replace(
        queryParameters: {
          'fromPlace': '${from.position.latitude},${from.position.longitude}',
          'toPlace': '${to.position.latitude},${to.position.longitude}',
          'mode': 'WALK',
          'date': date,
          'time': time,
          'numItineraries': '1',
        },
      );

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final plan = routing.Otp15ResponseParser.parsePlan(json);

      if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
        return plan.itineraries!.first;
      }
    } catch (e) {
      debugPrint('Walk route request failed: $e');
    }

    return null;
  }

  /// Detects itineraries where the same transit line appears consecutively
  /// (e.g., Line 209 → Line 209 with a transfer in between), which indicates
  /// an inefficient routing artifact from the routing engine.
  bool _hasRedundantSameLineTransfer(routing.Itinerary itinerary) {
    final transitLegs = itinerary.transitLegs;
    if (transitLegs.length < 2) return false;

    for (int i = 0; i < transitLegs.length - 1; i++) {
      final currentName = transitLegs[i].displayName;
      final nextName = transitLegs[i + 1].displayName;
      if (currentName.isNotEmpty && currentName == nextName) {
        return true;
      }
    }
    return false;
  }
}
