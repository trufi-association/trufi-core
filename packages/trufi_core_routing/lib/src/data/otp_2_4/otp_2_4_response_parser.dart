import 'package:latlong2/latlong.dart';

import '../../domain/entities/agency.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/leg.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/plan_location.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/transport_mode.dart';
import '../graphql/polyline_decoder.dart';
import '../utils/json_utils.dart';

/// Parses OTP 2.4 standard GraphQL responses into domain entities.
class Otp24ResponseParser {
  Otp24ResponseParser._();

  /// Parses a plan response from OTP 2.4.
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
      latitude: json.getDouble('lat'),
      longitude: json.getDouble('lon'),
    );
  }

  static List<Itinerary>? _parseItineraries(List<dynamic>? itineraries) {
    if (itineraries == null) return null;
    return itineraries
        .map((entry) => _parseItinerary(entry as Map<String, dynamic>))
        .toList();
  }

  static Itinerary _parseItinerary(Map<String, dynamic> json) {
    final legs = (json['legs'] as List<dynamic>?)
            ?.map((l) => _parseLeg(l as Map<String, dynamic>))
            .toList() ??
        [];

    return Itinerary(
      legs: legs,
      startTime: json.getDateTimeOr('startTime', DateTime.now()),
      endTime: json.getDateTimeOr('endTime', DateTime.now()),
      duration: json.getDurationOr('duration'),
      walkDistance: json.getDoubleOr('walkDistance', 0),
      walkTime: json.getDurationOr('walkTime'),
    );
  }

  static Leg _parseLeg(Map<String, dynamic> json) {
    final mode = json['mode'] as String? ?? 'WALK';
    final encodedPoints = json['legGeometry']?['points'] as String?;
    final decodedPoints = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    final routeData = json['route'] as Map<String, dynamic>?;

    return Leg(
      mode: mode,
      startTime: json.getDateTimeOr('startTime', DateTime.now()),
      endTime: json.getDateTimeOr('endTime', DateTime.now()),
      duration: json.getDurationOr('duration'),
      distance: json.getDoubleOr('distance', 0),
      transitLeg: json['transitLeg'] as bool? ?? false,
      encodedPoints: encodedPoints,
      decodedPoints: decodedPoints,
      route: routeData != null ? _parseRoute(routeData) : null,
      shortName: routeData?['shortName'] as String?,
      routeLongName: routeData?['longName'] as String? ?? '',
      agency: _parseAgencyFromRoute(routeData),
      fromPlace: _parsePlace(json['from']),
      toPlace: _parsePlace(json['to']),
      intermediatePlaces: _parseIntermediatePlaces(json['intermediatePlaces']),
      headsign: json['headsign'] as String?,
      rentedBike: json['rentedBike'] as bool?,
      interlineWithPreviousLeg: json['interlineWithPreviousLeg'] as bool?,
      realtimeState: json['realTime'] == true ? null : null,
    );
  }

  static Route _parseRoute(Map<String, dynamic> json) {
    final agencyData = json['agency'] as Map<String, dynamic>?;
    final modeStr = json['mode'] as String?;

    return Route(
      gtfsId: json['gtfsId'] as String?,
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
      mode: modeStr != null ? TransportModeExtension.fromString(modeStr) : null,
      agency: agencyData != null ? _parseAgency(agencyData) : null,
    );
  }

  static Agency? _parseAgencyFromRoute(Map<String, dynamic>? routeData) {
    if (routeData == null) return null;
    final agencyData = routeData['agency'] as Map<String, dynamic>?;
    if (agencyData == null) return null;
    return _parseAgency(agencyData);
  }

  static Agency _parseAgency(Map<String, dynamic> json) {
    return Agency(
      gtfsId: json['gtfsId'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
    );
  }

  static Place? _parsePlace(Map<String, dynamic>? json) {
    if (json == null) return null;
    final stopData = json['stop'] as Map<String, dynamic>?;
    return Place(
      name: json['name'] as String? ?? '',
      lat: json.getDoubleOr('lat', 0),
      lon: json.getDoubleOr('lon', 0),
      stopId: stopData?['gtfsId'] as String?,
      arrivalTime: json.getDateTime('arrivalTime'),
      departureTime: json.getDateTime('departureTime'),
    );
  }

  static List<Place>? _parseIntermediatePlaces(List<dynamic>? places) {
    if (places == null) return null;
    return places.map((p) {
      final json = p as Map<String, dynamic>;
      final stopData = json['stop'] as Map<String, dynamic>?;
      return Place(
        name: json['name'] as String? ?? '',
        lat: json.getDoubleOr('lat', 0),
        lon: json.getDoubleOr('lon', 0),
        stopId: stopData?['gtfsId'] as String?,
        arrivalTime: json.getDateTime('arrivalTime'),
        departureTime: json.getDateTime('departureTime'),
      );
    }).toList();
  }
}
