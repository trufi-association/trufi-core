import 'providers/routing_provider.dart';

/// Routing mode for the application.
enum ProviderSelectionMode {
  /// Uses the selected provider.
  selected,

  /// Tries online providers first, falls back to offline if they fail.
  autoFallback,
}

/// Configuration for routing with support for multiple providers.
///
/// Similar to how MapConfiguration works with multiple map engines,
/// this allows configuring multiple routing backends (OTP versions, offline, etc.)
/// that the user can switch between.
///
/// Example:
/// ```dart
/// final config = RoutingConfiguration(
///   providers: [
///     Otp28RoutingProvider(endpoint: 'https://otp.trufi.app'),
///     GtfsRoutingProvider(config: gtfsConfig),
///   ],
///   defaultMode: ProviderSelectionMode.autoFallback,
/// );
/// ```
class RoutingConfiguration {
  /// List of available routing providers.
  final List<IRoutingProvider> providers;

  /// ID of the default provider (uses first provider if not specified).
  final String? defaultProviderId;

  /// Default routing mode.
  final ProviderSelectionMode defaultMode;

  const RoutingConfiguration({
    required this.providers,
    this.defaultProviderId,
    this.defaultMode = ProviderSelectionMode.selected,
  }) : assert(providers.length > 0, 'At least one provider must be specified');

  /// Returns the default provider.
  IRoutingProvider get defaultProvider {
    if (defaultProviderId != null) {
      final provider = findProvider(defaultProviderId!);
      if (provider != null) return provider;
    }
    return providers.first;
  }

  /// Finds a provider by ID.
  IRoutingProvider? findProvider(String id) {
    for (final provider in providers) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  /// Returns providers that work offline.
  List<IRoutingProvider> get offlineProviders {
    return providers.where((p) => !p.requiresInternet).toList();
  }

  /// Returns providers that require internet.
  List<IRoutingProvider> get onlineProviders {
    return providers.where((p) => p.requiresInternet).toList();
  }

  /// Returns true if any offline provider is available.
  bool get hasOfflineProvider => offlineProviders.isNotEmpty;

  /// Returns true if any online provider is available.
  bool get hasOnlineProvider => onlineProviders.isNotEmpty;

  /// Returns providers that support listing transit routes.
  List<IRoutingProvider> get transitRouteProviders {
    return providers.where((p) => p.supportsTransitRoutes).toList();
  }

  /// Returns provider options for UI display.
  List<RoutingProviderOption> get providerOptions {
    return providers.toOptions();
  }

  /// Creates a copy of this configuration with the given values replaced.
  RoutingConfiguration copyWith({
    List<IRoutingProvider>? providers,
    String? defaultProviderId,
    ProviderSelectionMode? defaultMode,
  }) {
    return RoutingConfiguration(
      providers: providers ?? this.providers,
      defaultProviderId: defaultProviderId ?? this.defaultProviderId,
      defaultMode: defaultMode ?? this.defaultMode,
    );
  }
}
