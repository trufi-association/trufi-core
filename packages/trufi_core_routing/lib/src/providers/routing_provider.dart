import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../models/plan.dart';
import '../models/routing_location.dart';
import '../models/transit_route.dart';

/// Callback to provide extra HTTP headers for plan requests.
///
/// Headers are computed dynamically based on origin/destination.
/// Defined at the app level and injected into providers.
typedef PlanHeaderProvider =
    FutureOr<Map<String, String>> Function(
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

  /// Localized display name; defaults to [name].
  ///
  /// Override when the name should follow the app language. Mirrors
  /// `ITrufiMapEngine.localizedName`.
  String localizedName(BuildContext context) => name;

  /// Localized description; defaults to [description].
  ///
  /// Override when the description should follow the app language — UI
  /// selectors (settings, onboarding, routing sheet) call this instead of
  /// [description]. Mirrors `ITrufiMapEngine.localizedDescription`.
  String localizedDescription(BuildContext context) => description;

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

  /// Whether [buildPreferencesUI] offers settings the user can change.
  ///
  /// The home screen shows its route-settings button only when the current
  /// engine has configurable preferences or there is another engine to
  /// switch to. A single-engine app whose provider has nothing to configure
  /// (the local Trufi planner only ships an informational panel) therefore
  /// gets no button, instead of a sheet whose only action is an "Apply"
  /// that changes nothing (trufi-sanaa#23).
  ///
  /// Defaults to `true`: a provider written before this flag existed keeps
  /// the button it always had, and the worst a provider that forgets to
  /// override gets is the old sheet with nothing in it, never a lost form.
  /// Override to `false` when there is nothing the user can change: no
  /// [buildPreferencesUI] at all, or an informational panel like the local
  /// Trufi planner's.
  bool get hasConfigurablePreferences => true;

  /// Resets provider-specific preferences to defaults.
  void resetPreferences() {}

  /// Optional companion provider of live (GTFS-Realtime) vehicle positions.
  ///
  /// Return non-null when this routing engine has a paired source of live
  /// vehicle data (e.g. OTP 2.x with GTFS-RT vehiclePositions). When set,
  /// `trufi_core_home_screen` automatically:
  /// - Shows a "Live buses" toggle in the map settings sheet.
  /// - Renders interpolated bus markers on the map filtered by the selected
  ///   itinerary's routes.
  /// - Lets itinerary tiles render a "live" badge on matching routes.
  ///
  /// Default: null (no live vehicles).
  RealtimeVehiclesProvider? get realtimeVehiclesProvider => null;

  /// Telemetry source for the live ETA badges (#1004), when this engine has
  /// one: the home asks the *selected* engine, so an engine without
  /// telemetry shows no badge at all (#1018). Default: none.
  VehicleEtaProvider? get vehicleEtaProvider => null;
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
  ///
  /// Pass [context] so the option carries the localized name/description.
  RoutingProviderOption toOption([BuildContext? context]) {
    return RoutingProviderOption(
      id: id,
      name: context != null ? localizedName(context) : name,
      description: context != null
          ? localizedDescription(context)
          : description,
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
