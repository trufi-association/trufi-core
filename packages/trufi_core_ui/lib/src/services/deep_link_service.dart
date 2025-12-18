import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show SharedRoute, SharedRouteNotifier;

/// Service to handle deep links for route sharing
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final String? scheme;
  final void Function(SharedRoute route)? onRouteReceived;

  StreamSubscription<Uri>? _subscription;

  DeepLinkService({
    this.scheme,
    this.onRouteReceived,
  });

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

    // Check if scheme matches (if specified)
    if (scheme != null && uri.scheme != scheme) {
      debugPrint('DeepLinkService: Ignoring URI with scheme ${uri.scheme}');
      return;
    }

    final route = SharedRoute.fromUri(uri);
    if (route != null && onRouteReceived != null) {
      debugPrint('DeepLinkService: Parsed route: $route');
      onRouteReceived!(route);
    } else {
      debugPrint('DeepLinkService: Could not parse route from URI');
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
  }
}
