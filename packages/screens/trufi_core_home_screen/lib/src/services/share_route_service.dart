import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Localized strings for sharing routes
class ShareRouteStrings {
  final String Function(String appName) title;
  final String Function(String location) origin;
  final String Function(String location) destination;
  final String Function(String date) date;
  final String Function(String departure, String arrival) times;
  final String Function(String duration) duration;
  final String Function(String summary) itinerary;
  final String openInApp;

  const ShareRouteStrings({
    required this.title,
    required this.origin,
    required this.destination,
    required this.date,
    required this.times,
    required this.duration,
    required this.itinerary,
    required this.openInApp,
  });
}

/// Service for sharing route information
class ShareRouteService {
  /// Shares a route with text and deep link
  static Future<void> shareRoute({
    required TrufiLocation from,
    required TrufiLocation to,
    required routing.Itinerary itinerary,
    required ShareRouteStrings strings,
    int? selectedItineraryIndex,
    required String appName,
    String? deepLinkScheme,
  }) async {
    final text = generateShareText(
      from: from,
      to: to,
      itinerary: itinerary,
      strings: strings,
      selectedItineraryIndex: selectedItineraryIndex,
      appName: appName,
      deepLinkScheme: deepLinkScheme,
    );

    await Share.share(text);
  }

  /// Generates human-readable text for sharing
  static String generateShareText({
    required TrufiLocation from,
    required TrufiLocation to,
    required routing.Itinerary itinerary,
    required ShareRouteStrings strings,
    int? selectedItineraryIndex,
    required String appName,
    String? deepLinkScheme,
  }) {
    final buffer = StringBuffer();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Header
    buffer.writeln('🚌 ${strings.title(appName)}');
    buffer.writeln();

    // Origin and destination
    buffer.writeln('📍 ${strings.origin(from.description)}');
    buffer.writeln('📍 ${strings.destination(to.description)}');
    buffer.writeln();

    // Date and time
    buffer.writeln(
      '📅 ${strings.date(dateFormat.format(itinerary.startTime))}',
    );
    buffer.writeln(
      '🕐 ${strings.times(timeFormat.format(itinerary.startTime), timeFormat.format(itinerary.endTime))}',
    );
    buffer.writeln(
      '⏱️ ${strings.duration(_formatDuration(itinerary.duration))}',
    );
    buffer.writeln();

    // Route summary
    buffer.writeln('🚍 ${strings.itinerary(_generateRouteSummary(itinerary))}');

    // Deep link
    if (deepLinkScheme != null) {
      buffer.writeln();
      buffer.writeln('📲 ${strings.openInApp}');
      buffer.writeln(
        generateDeepLink(
          from: from,
          to: to,
          itinerary: itinerary,
          selectedItineraryIndex: selectedItineraryIndex,
          scheme: deepLinkScheme,
        ),
      );
    }

    return buffer.toString();
  }

  /// Generates a deep link URL for the route (custom scheme for mobile)
  static String generateDeepLink({
    required TrufiLocation from,
    required TrufiLocation to,
    required routing.Itinerary itinerary,
    int? selectedItineraryIndex,
    String scheme = 'trufiapp',
  }) {
    final params = _buildRouteParams(
      from: from,
      to: to,
      itinerary: itinerary,
      selectedItineraryIndex: selectedItineraryIndex,
    );

    final uri = Uri(scheme: scheme, host: 'route', queryParameters: params);

    return uri.toString();
  }

  /// Generates a web URL for the route (for sharing on web)
  static String generateWebLink({
    required TrufiLocation from,
    required TrufiLocation to,
    required routing.Itinerary itinerary,
    int? selectedItineraryIndex,
    required String baseUrl,
  }) {
    final params = _buildRouteParams(
      from: from,
      to: to,
      itinerary: itinerary,
      selectedItineraryIndex: selectedItineraryIndex,
    );

    final baseUri = Uri.parse(baseUrl);
    final uri = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: '/route',
      queryParameters: params,
    );

    return uri.toString();
  }

  /// Builds the query parameters for route sharing
  static Map<String, String> _buildRouteParams({
    required TrufiLocation from,
    required TrufiLocation to,
    required routing.Itinerary itinerary,
    int? selectedItineraryIndex,
  }) {
    return {
      'fromLat': from.latitude.toString(),
      'fromLng': from.longitude.toString(),
      'fromName': from.description,
      'toLat': to.latitude.toString(),
      'toLng': to.longitude.toString(),
      'toName': to.description,
      'time': itinerary.startTime.millisecondsSinceEpoch.toString(),
      if (selectedItineraryIndex != null)
        'itinerary': selectedItineraryIndex.toString(),
    };
  }

  /// Generates a summary of the route legs
  static String _generateRouteSummary(routing.Itinerary itinerary) {
    final parts = <String>[];

    for (final leg in itinerary.legs) {
      if (leg.transportMode == routing.TransportMode.walk) {
        parts.add('🚶 ${leg.duration.inMinutes}min');
      } else if (leg.transportMode == routing.TransportMode.bicycle) {
        parts.add('🚴 ${leg.duration.inMinutes}min');
      } else {
        // Transit leg
        final icon = _getModeEmoji(leg.transportMode);
        final name = leg.shortName ?? leg.route?.shortName ?? '';
        if (name.isNotEmpty) {
          parts.add('$icon $name');
        } else {
          parts.add(icon);
        }
      }
    }

    return parts.join(' → ');
  }

  /// Gets emoji for transport mode
  static String _getModeEmoji(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
        return '🚌';
      case routing.TransportMode.rail:
        return '🚆';
      case routing.TransportMode.subway:
        return '🚇';
      case routing.TransportMode.tram:
        return '🚊';
      case routing.TransportMode.ferry:
        return '⛴️';
      case routing.TransportMode.walk:
        return '🚶';
      case routing.TransportMode.bicycle:
        return '🚴';
      case routing.TransportMode.car:
        return '🚗';
      default:
        return '🚍';
    }
  }

  /// Formats duration as human-readable string
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '$minutes min';
  }
}
