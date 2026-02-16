import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/plan.dart';
import '../models/routing_location.dart';
import '../models/transit_route.dart';

/// Callback to provide extra HTTP headers for plan requests.
///
/// Headers are computed dynamically based on origin/destination.
/// Defined at the app level and injected into providers.
typedef PlanHeaderProvider = FutureOr<Map<String, String>> Function(
  RoutingLocation from,
  RoutingLocation to,
);

/// Interface for routing providers.
///
/// Implement this interface to create custom routing backends
/// that can be used with RoutingEngineManager.
///
/// Example implementation:
/// ```dart
/// class CustomRoutingProvider implements IRoutingProvider {
///   @override
///   String get id => 'custom';
///
///   @override
///   String get name => 'Custom Routing';
///
///   @override
///   String get description => 'My custom routing backend';
///
///   @override
///   bool get supportsTransitRoutes => false;
///
///   @override
///   bool get requiresInternet => true;
///
///   @override
///   Future<Plan> fetchPlan({...}) async { ... }
///
///   @override
///   Future<List<TransitRoute>> fetchTransitRoutes() async => [];
///
///   @override
///   Future<TransitRoute?> fetchTransitRouteById(String id) async => null;
/// }
/// ```
abstract class IRoutingProvider {
  /// Unique identifier for this provider.
  String get id;

  /// Display name shown in UI selectors.
  String get name;

  /// Description of this provider.
  String get description;

  /// Whether this provider supports listing transit routes.
  bool get supportsTransitRoutes;

  /// Whether this provider requires internet connection.
  bool get requiresInternet;

  /// Initialize the provider.
  ///
  /// Called during app startup to prepare any resources needed by the provider.
  /// For online providers (e.g., OTP), this is typically a no-op.
  /// For offline providers (e.g., GTFS), this loads and indexes the data.
  ///
  /// Default implementation does nothing.
  Future<void> initialize() async {}

  /// Fetches a trip plan from origin to destination.
  ///
  /// Each provider reads its own internal preferences (wheelchair, walkSpeed,
  /// etc.) when building the request. The caller only provides trip-level
  /// parameters: origin, destination, time, and direction.
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  });

  /// Fetches all transit routes.
  ///
  /// Returns an empty list if this provider doesn't support transit routes.
  Future<List<TransitRoute>> fetchTransitRoutes();

  /// Fetches a transit route by ID.
  ///
  /// Returns null if the route is not found or transit routes are not supported.
  Future<TransitRoute?> fetchTransitRouteById(String id);

  /// Builds the preferences UI for this provider.
  ///
  /// The provider injects its own internal state into the widget.
  /// Returns null if this provider has no configurable preferences.
  Widget? buildPreferencesUI(BuildContext context) => null;

  /// Resets provider-specific preferences to defaults.
  void resetPreferences() {}
}

/// Option for routing provider selection UI.
class RoutingProviderOption {
  final String id;
  final String name;
  final String description;
  final bool requiresInternet;

  const RoutingProviderOption({
    required this.id,
    required this.name,
    required this.description,
    required this.requiresInternet,
  });
}

/// Extension methods for IRoutingProvider.
extension RoutingProviderExtension on IRoutingProvider {
  /// Converts this provider to a RoutingProviderOption for use in UI.
  RoutingProviderOption toOption() {
    return RoutingProviderOption(
      id: id,
      name: name,
      description: description,
      requiresInternet: requiresInternet,
    );
  }
}

/// Extension to convert a list of providers to RoutingProviderOptions.
extension RoutingProviderListExtension on List<IRoutingProvider> {
  /// Converts all providers to RoutingProviderOptions.
  List<RoutingProviderOption> toOptions() {
    return map((e) => e.toOption()).toList();
  }

  /// Finds a provider by ID.
  IRoutingProvider? findById(String id) {
    for (final provider in this) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  /// Returns providers that work offline.
  List<IRoutingProvider> get offlineProviders {
    return where((p) => !p.requiresInternet).toList();
  }

  /// Returns providers that require internet.
  List<IRoutingProvider> get onlineProviders {
    return where((p) => p.requiresInternet).toList();
  }
}
