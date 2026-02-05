import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'request_plan_service.dart';

/// A RequestPlanService that can switch between multiple routing providers
/// and optionally fall back to offline routing when online fails.
///
/// Example usage:
/// ```dart
/// final service = HybridRequestPlanService(
///   routingConfiguration: config,
///   initialProviderId: 'otp_2_8',
///   mode: ProviderSelectionMode.autoFallback,
/// );
/// ```
class HybridRequestPlanService implements RequestPlanService {
  final routing.RoutingConfiguration _config;

  /// Currently selected provider ID.
  String _currentProviderId;

  /// Current selection mode.
  routing.ProviderSelectionMode _mode;

  /// Cached repositories by provider ID.
  final Map<String, routing.PlanRepository> _repositories = {};

  HybridRequestPlanService({
    required routing.RoutingConfiguration routingConfiguration,
    String? initialProviderId,
    routing.ProviderSelectionMode? mode,
  })  : _config = routingConfiguration,
        _currentProviderId =
            initialProviderId ?? routingConfiguration.defaultProvider.id,
        _mode = mode ?? routingConfiguration.defaultMode;

  /// Returns the currently selected provider.
  routing.IRoutingProvider get currentProvider {
    return _config.findProvider(_currentProviderId) ?? _config.defaultProvider;
  }

  /// Returns the current provider ID.
  String get currentProviderId => _currentProviderId;

  /// Returns the current selection mode.
  routing.ProviderSelectionMode get mode => _mode;

  /// Returns all available providers.
  List<routing.IRoutingProvider> get providers => _config.providers;

  /// Returns true if offline routing is available.
  bool get hasOfflineProvider => _config.hasOfflineProvider;

  /// Sets the current provider by ID.
  void setProvider(String providerId) {
    if (_config.findProvider(providerId) != null) {
      _currentProviderId = providerId;
    }
  }

  /// Sets the selection mode.
  void setMode(routing.ProviderSelectionMode mode) {
    _mode = mode;
  }

  /// Pre-loads data for a specific provider (if it supports preloading).
  /// This is useful for offline providers that need to load large data files.
  Future<void> preloadProvider(String providerId) async {
    final provider = _config.findProvider(providerId);
    if (provider == null) return;

    debugPrint('🔄 Pre-loading provider: $providerId');
    final repository = _getRepository(provider);

    // Check if this repository supports preloading (GtfsPlanRepository)
    if (repository is routing.GtfsPlanRepository) {
      if (!repository.isLoaded && !repository.isLoading) {
        await repository.preload();
        debugPrint('✅ Provider $providerId pre-loaded');
      } else if (repository.isLoaded) {
        debugPrint('✅ Provider $providerId already loaded');
      }
    }
  }

  /// Gets or creates a repository for a provider.
  routing.PlanRepository _getRepository(routing.IRoutingProvider provider) {
    return _repositories.putIfAbsent(
      provider.id,
      () => provider.createPlanRepository(),
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
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 ROUTING REQUEST STARTED');
    debugPrint('║ Mode: $_mode');
    debugPrint('║ Current provider: $_currentProviderId');
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
      switch (_mode) {
        case routing.ProviderSelectionMode.selected:
          debugPrint('║ Using SELECTED mode with provider: ${currentProvider.id}');
          final result = await _fetchWithProvider(
            provider: currentProvider,
            from: routingFrom,
            to: routingTo,
            locale: locale,
            dateTime: effectiveDateTime,
            arriveBy: arriveBy,
            preferences: preferences,
          );
          totalStopwatch.stop();
          _logSuccess(result, totalStopwatch.elapsedMilliseconds);
          return result;

        case routing.ProviderSelectionMode.autoFallback:
          debugPrint('║ Using AUTO_FALLBACK mode');
          // Try online providers first
          final onlineProviders = _config.onlineProviders;
          final offlineProviders = _config.offlineProviders;

          // Try the current provider first if it's online
          if (currentProvider.requiresInternet) {
            try {
              final result = await _fetchWithProvider(
                provider: currentProvider,
                from: routingFrom,
                to: routingTo,
                locale: locale,
                dateTime: effectiveDateTime,
                arriveBy: arriveBy,
                preferences: preferences,
              );
              totalStopwatch.stop();
              _logSuccess(result, totalStopwatch.elapsedMilliseconds);
              return result;
            } catch (e) {
              debugPrint('║ ❌ Online provider ${currentProvider.id} FAILED: $e');
            }
          }

          // Try other online providers
          for (final provider in onlineProviders) {
            if (provider.id == currentProvider.id) continue;
            try {
              final result = await _fetchWithProvider(
                provider: provider,
                from: routingFrom,
                to: routingTo,
                locale: locale,
                dateTime: effectiveDateTime,
                arriveBy: arriveBy,
                preferences: preferences,
              );
              totalStopwatch.stop();
              _logSuccess(result, totalStopwatch.elapsedMilliseconds);
              return result;
            } catch (e) {
              debugPrint('║ ❌ Online provider ${provider.id} FAILED: $e');
            }
          }

          // Fall back to offline providers
          for (final provider in offlineProviders) {
            try {
              debugPrint('║ 🔄 FALLBACK to offline provider: ${provider.id}');
              final result = await _fetchWithProvider(
                provider: provider,
                from: routingFrom,
                to: routingTo,
                locale: locale,
                dateTime: effectiveDateTime,
                arriveBy: arriveBy,
                preferences: preferences,
              );
              totalStopwatch.stop();
              _logSuccess(result, totalStopwatch.elapsedMilliseconds);
              return result;
            } catch (e) {
              debugPrint('║ ❌ Offline provider ${provider.id} FAILED: $e');
            }
          }

          // All providers failed
          totalStopwatch.stop();
          debugPrint('║ ❌ ALL PROVIDERS FAILED');
          debugPrint('║ Total time: ${totalStopwatch.elapsedMilliseconds}ms');
          debugPrint('╚══════════════════════════════════════════════════════════════');
          throw Exception('No se pudo obtener la ruta. Todos los proveedores fallaron.');
      }
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

  Future<routing.Plan> _fetchWithProvider({
    required routing.IRoutingProvider provider,
    required routing.RoutingLocation from,
    required routing.RoutingLocation to,
    String? locale,
    required DateTime dateTime,
    required bool arriveBy,
    routing.RoutingPreferences? preferences,
  }) async {
    final stopwatch = Stopwatch()..start();
    final isOnline = provider.requiresInternet;
    debugPrint('║ ⏳ Trying provider: ${provider.id} (${isOnline ? "online" : "offline"})');

    final repository = _getRepository(provider);

    final plan = await repository.fetchPlan(
      from: from,
      to: to,
      locale: locale,
      dateTime: dateTime,
      arriveBy: arriveBy,
      preferences: preferences,
    );

    stopwatch.stop();
    final count = plan.itineraries?.length ?? 0;
    debugPrint('║ ✅ Provider ${provider.id} returned $count itineraries in ${stopwatch.elapsedMilliseconds}ms');

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
