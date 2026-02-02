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
    print('[OTP24] parsePlan called with keys: ${json.keys.toList()}');
    final planData = json['plan'] as Map<String, dynamic>?;
    if (planData == null) {
      print('[OTP24] planData is null, returning empty Plan');
      return const Plan();
    }
    print('[OTP24] planData keys: ${planData.keys.toList()}');

    try {
      final plan = Plan(
        from: _parsePlanLocation(planData['from']),
        to: _parsePlanLocation(planData['to']),
        itineraries: _parseItineraries(planData['itineraries']),
      );
      print('[OTP24] Plan parsed successfully with ${plan.itineraries?.length ?? 0} itineraries');
      return plan;
    } catch (e, stack) {
      print('[OTP24] Error parsing plan: $e');
      print('[OTP24] Stack: $stack');
      rethrow;
    }
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
    print('[OTP24] Parsing ${itineraries.length} itineraries');
    return itineraries.asMap().entries.map((entry) {
      print('[OTP24] Parsing itinerary ${entry.key}');
      try {
        return _parseItinerary(entry.value as Map<String, dynamic>);
      } catch (e, stack) {
        print('[OTP24] Error parsing itinerary ${entry.key}: $e');
        print('[OTP24] Stack: $stack');
        rethrow;
      }
    }).toList();
  }

  static Itinerary _parseItinerary(Map<String, dynamic> json) {
    print('[OTP24] _parseItinerary keys: ${json.keys.toList()}');
    print('[OTP24] Raw values - startTime: ${json['startTime']} (${json['startTime'].runtimeType}), duration: ${json['duration']} (${json['duration'].runtimeType})');

    final legs = (json['legs'] as List<dynamic>?)
            ?.map((l) => _parseLeg(l as Map<String, dynamic>))
            .toList() ??
        [];

    final itinerary = Itinerary(
      legs: legs,
      startTime: json.getDateTimeOr('startTime', DateTime.now()),
      endTime: json.getDateTimeOr('endTime', DateTime.now()),
      duration: json.getDurationOr('duration'),
      walkDistance: json.getDoubleOr('walkDistance', 0),
      walkTime: json.getDurationOr('walkTime'),
    );
    print('[OTP24] Itinerary parsed: startTime=${itinerary.startTime}, duration=${itinerary.duration}');
    return itinerary;
  }

  static Leg _parseLeg(Map<String, dynamic> json) {
    print('[OTP24] _parseLeg keys: ${json.keys.toList()}');
    print('[OTP24] Leg raw - mode: ${json['mode']}, startTime: ${json['startTime']} (${json['startTime']?.runtimeType}), distance: ${json['distance']} (${json['distance']?.runtimeType})');

    final mode = json['mode'] as String? ?? 'WALK';
    final encodedPoints = json['legGeometry']?['points'] as String?;
    final decodedPoints = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    final routeData = json['route'] as Map<String, dynamic>?;

    try {
      final leg = Leg(
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
      print('[OTP24] Leg parsed: mode=$mode, distance=${leg.distance}');
      return leg;
    } catch (e, stack) {
      print('[OTP24] Error parsing leg: $e');
      print('[OTP24] Stack: $stack');
      rethrow;
    }
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
