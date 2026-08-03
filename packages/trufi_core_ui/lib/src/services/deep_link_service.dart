import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show SharedRoute, SharedRouteNotifier;

/// Service to handle deep links for route sharing and in-app navigation
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final String? scheme;
  final void Function(SharedRoute route)? onRouteReceived;

  /// Called with an in-app location (path + query, e.g.
  /// `/routes?operator=X`) for links that are not shared-route links,
  /// so hosts can forward them to their router. See
  /// [resolveInAppLocation] for how links map to locations.
  final void Function(String location)? onLocationReceived;

  StreamSubscription<Uri>? _subscription;

  DeepLinkService({this.scheme, this.onRouteReceived, this.onLocationReceived});

  /// Initialize the deep link service
  Future<void> initialize() async {
    // Handle initial link (app was opened via deep link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link: $e');
    }

    // Listen for incoming links while app is running
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) {
        debugPrint('DeepLinkService: Error in link stream: $e');
      },
    );
  }

  void _handleUri(Uri uri) {
    debugPrint('DeepLinkService: Received URI: $uri');

    // Check if scheme matches (if specified), but always allow https
    if (scheme != null && uri.scheme != scheme && uri.scheme != 'https') {
      debugPrint('DeepLinkService: Ignoring URI with scheme ${uri.scheme}');
      return;
    }

    final route = SharedRoute.fromUri(uri);
    if (route != null && onRouteReceived != null) {
      debugPrint('DeepLinkService: Parsed route: $route');
      onRouteReceived!(route);
      return;
    }

    // Not a shared-route link — surface it as an in-app location so the
    // host can navigate (e.g. trufi://routes?operator=X to the routes
    // screen filtered by operator).
    final location = resolveInAppLocation(uri);
    if (location != null && onLocationReceived != null) {
      debugPrint('DeepLinkService: Forwarding location: $location');
      onLocationReceived!(location);
    } else {
      debugPrint('DeepLinkService: Could not parse route from URI');
    }
  }

  /// Maps a deep-link URI to an in-app location (path + query).
  ///
  /// For custom schemes the host is the first path segment
  /// (`trufi://routes?operator=X` → `/routes?operator=X`); for
  /// http(s) links the path is used as-is
  /// (`https://app.example.com/routes?operator=X` → `/routes?operator=X`).
  /// Returns null when the link carries no usable path (e.g. a bare
  /// domain), so callers can ignore it.
  static String? resolveInAppLocation(Uri uri) {
    final isWebLink = uri.scheme == 'http' || uri.scheme == 'https';
    final path = isWebLink || uri.host.isEmpty
        ? uri.path
        : '/${uri.host}${uri.path}';
    if (path.isEmpty || path == '/') return null;
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    return '$path$query';
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
  }
}
