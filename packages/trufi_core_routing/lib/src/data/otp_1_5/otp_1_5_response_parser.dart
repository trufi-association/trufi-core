import 'package:latlong2/latlong.dart';

import '../../domain/entities/agency.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/itinerary_leg.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/plan_location.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/transport_mode.dart';
import '../../domain/entities/vertex_type.dart';
import '../graphql/polyline_decoder.dart';

/// Parses OTP 1.5 REST API JSON responses into domain entities.
class Otp15ResponseParser {
  Otp15ResponseParser._();

  /// Parses a plan response from OTP 1.5 REST API.
  static Plan parsePlan(Map<String, dynamic> json) {
    final planData = json['plan'] as Map<String, dynamic>?;
    if (planData == null) {
      return const Plan();
    }

    return Plan(
      from: _parsePlanLocation(planData['from']),
      to: _parsePlanLocation(planData['to']),
      itineraries: _parseItineraries(planData['itineraries']),
    );
  }

  static PlanLocation? _parsePlanLocation(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PlanLocation(
      name: json['name'] as String?,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lon'] as num?)?.toDouble(),
    );
  }

  static List<Itinerary>? _parseItineraries(List<dynamic>? itineraries) {
    if (itineraries == null) return null;
    return itineraries
        .map((i) => _parseItinerary(i as Map<String, dynamic>))
        .toList();
  }

  static Itinerary _parseItinerary(Map<String, dynamic> json) {
    final legs = (json['legs'] as List<dynamic>?)
            ?.map((l) => _parseLeg(l as Map<String, dynamic>))
            .toList() ??
        [];

    // OTP 1.5 returns times in milliseconds since epoch
    final startTime = json['startTime'] as int?;
    final endTime = json['endTime'] as int?;

    return Itinerary(
      legs: legs,
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : DateTime.now(),
      endTime: endTime != null
          ? DateTime.fromMillisecondsSinceEpoch(endTime)
          : DateTime.now(),
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      walkDistance: (json['walkDistance'] as num?)?.toDouble() ?? 0,
      walkTime: Duration(seconds: json['walkTime'] as int? ?? 0),
    );
  }

  static ItineraryLeg _parseLeg(Map<String, dynamic> json) {
    final mode = json['mode'] as String? ?? 'WALK';
    final encodedPoints = json['legGeometry']?['points'] as String?;
    final decodedPoints = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    // OTP 1.5 returns times in milliseconds since epoch
    final startTime = json['startTime'] as int?;
    final endTime = json['endTime'] as int?;

    return ItineraryLeg(
      mode: mode,
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : DateTime.now(),
      endTime: endTime != null
          ? DateTime.fromMillisecondsSinceEpoch(endTime)
          : DateTime.now(),
      duration: Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      transitLeg: json['transitLeg'] as bool? ?? false,
      encodedPoints: encodedPoints,
      decodedPoints: decodedPoints,
      route: _parseRoute(json),
      shortName: json['routeShortName'] as String?,
      routeLongName: json['routeLongName'] as String? ?? '',
      agency: _parseAgency(json),
      fromPlace: _parsePlace(json['from']),
      toPlace: _parsePlace(json['to']),
      intermediatePlaces: _parseIntermediatePlaces(json['intermediateStops']),
      headsign: json['headsign'] as String?,
      rentedBike: json['rentedBike'] as bool?,
      interlineWithPreviousLeg: json['interlineWithPreviousLeg'] as bool?,
      realtimeState: json['realTime'] == true ? null : null,
    );
  }

  static Route? _parseRoute(Map<String, dynamic> json) {
    // OTP 1.5 REST API includes route info directly in the leg
    final routeId = json['routeId'] as String?;
    if (routeId == null && json['routeShortName'] == null) {
      return null;
    }

    final modeStr = json['mode'] as String?;

    return Route(
      gtfsId: routeId,
      shortName: json['routeShortName'] as String?,
      longName: json['routeLongName'] as String?,
      color: json['routeColor'] as String?,
      textColor: json['routeTextColor'] as String?,
      mode: modeStr != null ? TransportModeExtension.fromString(modeStr) : null,
      agency: _parseAgency(json),
    );
  }

  static Agency? _parseAgency(Map<String, dynamic> json) {
    // OTP 1.5 REST API includes agency info directly in the leg
    final agencyName = json['agencyName'] as String?;
    if (agencyName == null) return null;

    return Agency(
      gtfsId: json['agencyId'] as String?,
      name: agencyName,
      url: json['agencyUrl'] as String?,
    );
  }

  static Place? _parsePlace(Map<String, dynamic>? json) {
    if (json == null) return null;

    final vertexTypeStr = json['vertexType'] as String?;
    final vertexType = VertexTypeExtension.fromString(vertexTypeStr);

    return Place(
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      stopId: json['stopId'] as String?,
      vertexType: vertexType,
      arrivalTime: json['arrival'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['arrival'] as int)
          : null,
      departureTime: json['departure'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['departure'] as int)
          : null,
    );
  }

  static List<Place>? _parseIntermediatePlaces(List<dynamic>? stops) {
    if (stops == null) return null;
    return stops.map((s) {
      final json = s as Map<String, dynamic>;
      return Place(
        name: json['name'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        stopId: json['stopId'] as String?,
        arrivalTime: json['arrival'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['arrival'] as int)
            : null,
        departureTime: json['departure'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['departure'] as int)
            : null,
      );
    }).toList();
  }
}
