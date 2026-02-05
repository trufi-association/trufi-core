import '../domain/entities/routing_capabilities.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/transit_route_repository.dart';

/// Interface for routing providers.
///
/// Similar to ITrufiMapEngine but for routing. Implement this interface
/// to create custom routing backends that can be used with RoutingConfiguration.
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
///   PlanRepository createPlanRepository() => MyCustomPlanRepository();
///
///   @override
///   TransitRouteRepository? createTransitRouteRepository() => null;
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

  /// The routing capabilities supported by this provider.
  ///
  /// UI should adapt based on these capabilities to show only relevant options.
  RoutingCapabilities get capabilities;

  /// Creates the PlanRepository for fetching trip plans.
  PlanRepository createPlanRepository();

  /// Creates the TransitRouteRepository for listing transit routes.
  /// Returns null if this provider doesn't support transit routes.
  TransitRouteRepository? createTransitRouteRepository();
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
