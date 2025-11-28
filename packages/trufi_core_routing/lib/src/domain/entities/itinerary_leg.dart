import 'package:latlong2/latlong.dart';

import '../../data/graphql/polyline_decoder.dart';
import 'agency.dart';
import 'place.dart';
import 'realtime_state.dart';
import 'route.dart';
import 'step.dart';
import 'transport_mode.dart';

/// A leg of an itinerary (walking, transit, etc.).
class ItineraryLeg {
  const ItineraryLeg({
    required this.mode,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.transitLeg,
    this.encodedPoints,
    this.decodedPoints = const [],
    this.route,
    this.shortName,
    this.routeLongName,
    this.agency,
    this.realtimeState,
    this.fromPlace,
    this.toPlace,
    this.steps,
    this.intermediatePlaces,
    this.rentedBike,
    this.interlineWithPreviousLeg,
    this.headsign,
  });

  final String mode;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double distance;
  final bool transitLeg;
  final String? encodedPoints;
  final List<LatLng> decodedPoints;
  final Route? route;
  final String? shortName;
  final String? routeLongName;
  final Agency? agency;
  final RealtimeState? realtimeState;
  final Place? fromPlace;
  final Place? toPlace;
  final List<Step>? steps;
  final List<Place>? intermediatePlaces;
  final bool? rentedBike;
  final bool? interlineWithPreviousLeg;
  final String? headsign;

  /// Returns the transport mode enum.
  TransportMode get transportMode => TransportModeExtension.fromString(
        mode,
        specificTransport: routeLongName,
      );

  /// Creates an [ItineraryLeg] from JSON.
  factory ItineraryLeg.fromJson(
    Map<String, dynamic> json, {
    List<LatLng> Function(String)? polylineDecoder,
  }) {
    final encodedPoints = json['legGeometry']?['points'] as String?;
    final decoder = polylineDecoder ?? PolylineDecoder.decode;
    final decodedPoints = encodedPoints != null
        ? decoder(encodedPoints)
        : <LatLng>[];

    return ItineraryLeg(
      mode: json['mode'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      duration: Duration(seconds: json['duration'] as int),
      distance: (json['distance'] as num).toDouble(),
      transitLeg: json['transitLeg'] as bool,
      encodedPoints: encodedPoints,
      decodedPoints: decodedPoints,
      route: _parseRoute(json['route']),
      shortName: _parseShortName(json['route']),
      routeLongName: json['routeLongName'] as String? ?? '',
      agency: json['agency'] != null
          ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
          : null,
      realtimeState:
          RealtimeStateExtension.fromString(json['realtimeState'] as String?),
      fromPlace: json['fromPlace'] != null
          ? Place.fromJson(json['fromPlace'] as Map<String, dynamic>)
          : null,
      toPlace: json['toPlace'] != null
          ? Place.fromJson(json['toPlace'] as Map<String, dynamic>)
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List<dynamic>)
              .map((e) => Step.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      intermediatePlaces: json['intermediatePlaces'] != null
          ? (json['intermediatePlaces'] as List<dynamic>)
              .map((e) => Place.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      rentedBike: json['rentedBike'] as bool?,
      interlineWithPreviousLeg: json['interlineWithPreviousLeg'] as bool?,
      headsign: json['headsign'] as String?,
    );
  }

  static Route? _parseRoute(dynamic routeData) {
    if (routeData == null) return null;
    if (routeData is Map<String, dynamic>) {
      return Route.fromJson(routeData);
    }
    return null;
  }

  static String? _parseShortName(dynamic routeData) {
    if (routeData == null) return null;
    if (routeData is String && routeData.isNotEmpty) {
      return routeData;
    }
    if (routeData is Map<String, dynamic>) {
      return routeData['shortName'] as String?;
    }
    return null;
  }

  /// Converts this leg to JSON.
  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
      'distance': distance,
      'transitLeg': transitLeg,
      'legGeometry': {'points': encodedPoints},
      'route': route?.toJson() ?? shortName,
      'routeLongName': routeLongName,
      'agency': agency?.toJson(),
      'realtimeState': realtimeState?.name,
      'fromPlace': fromPlace?.toJson(),
      'toPlace': toPlace?.toJson(),
      'steps': steps?.map((e) => e.toJson()).toList(),
      'intermediatePlaces': intermediatePlaces?.map((e) => e.toJson()).toList(),
      'rentedBike': rentedBike,
      'interlineWithPreviousLeg': interlineWithPreviousLeg,
      'headsign': headsign,
    };
  }

  /// Returns the route color or a default color.
  String get routeColor => route?.color ?? 'd81b60';

  /// Returns the display name for the route.
  String get displayName => route?.shortName ?? shortName ?? '';
}
