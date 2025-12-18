import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Represents a shared route received via deep link
class SharedRoute {
  final double fromLat;
  final double fromLng;
  final String fromName;
  final double toLat;
  final double toLng;
  final String toName;
  final DateTime? time;
  final int? selectedItineraryIndex;

  const SharedRoute({
    required this.fromLat,
    required this.fromLng,
    required this.fromName,
    required this.toLat,
    required this.toLng,
    required this.toName,
    this.time,
    this.selectedItineraryIndex,
  });

  /// Parse a deep link URI into a SharedRoute
  /// Expected format: trufiapp://route?fromLat=...&fromLng=...&fromName=...&toLat=...&toLng=...&toName=...&time=...&itinerary=...
  static SharedRoute? fromUri(Uri uri) {
    if (uri.host != 'route') return null;

    final params = uri.queryParameters;

    final fromLat = double.tryParse(params['fromLat'] ?? '');
    final fromLng = double.tryParse(params['fromLng'] ?? '');
    final fromName = params['fromName'];
    final toLat = double.tryParse(params['toLat'] ?? '');
    final toLng = double.tryParse(params['toLng'] ?? '');
    final toName = params['toName'];
    final timeMs = int.tryParse(params['time'] ?? '');
    final itineraryIndex = int.tryParse(params['itinerary'] ?? '');

    if (fromLat == null ||
        fromLng == null ||
        fromName == null ||
        toLat == null ||
        toLng == null ||
        toName == null) {
      return null;
    }

    return SharedRoute(
      fromLat: fromLat,
      fromLng: fromLng,
      fromName: fromName,
      toLat: toLat,
      toLng: toLng,
      toName: toName,
      time: timeMs != null
          ? DateTime.fromMillisecondsSinceEpoch(timeMs)
          : null,
      selectedItineraryIndex: itineraryIndex,
    );
  }

  @override
  String toString() {
    return 'SharedRoute(from: $fromName ($fromLat, $fromLng), to: $toName ($toLat, $toLng), time: $time, itinerary: $selectedItineraryIndex)';
  }
}

/// Notifier that holds the current shared route from deep links
class SharedRouteNotifier extends ChangeNotifier {
  SharedRoute? _pendingRoute;

  /// The pending route from a deep link, if any
  SharedRoute? get pendingRoute => _pendingRoute;

  /// Set a pending route (called by DeepLinkService)
  void setPendingRoute(SharedRoute route) {
    _pendingRoute = route;
    notifyListeners();
  }

  /// Clear the pending route (call after consuming it)
  void clearPendingRoute() {
    _pendingRoute = null;
    notifyListeners();
  }

  /// Static accessor for reading from context
  static SharedRouteNotifier read(BuildContext context) {
    return Provider.of<SharedRouteNotifier>(context, listen: false);
  }

  /// Static accessor for watching from context
  static SharedRouteNotifier watch(BuildContext context) {
    return Provider.of<SharedRouteNotifier>(context);
  }
}
