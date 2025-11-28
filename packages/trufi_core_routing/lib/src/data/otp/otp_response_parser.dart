import 'package:latlong2/latlong.dart';

import '../../domain/entities/agency.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/itinerary_leg.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/plan_location.dart';
import '../../domain/entities/route.dart';
import '../graphql/polyline_decoder.dart';

/// Parses OTP 2.7 responses into domain entities.
class OtpResponseParser {
  OtpResponseParser._();

  /// Parses a trip response from OTP 2.7.
  static Plan parseTrip(Map<String, dynamic> json) {
    final tripData = json['trip'] as Map<String, dynamic>?;
    if (tripData == null) {
      return const Plan();
    }

    return Plan(
      from: _parsePlanLocation(tripData['fromPlace']),
      to: _parsePlanLocation(tripData['toPlace']),
      itineraries: _parseTripPatterns(tripData['tripPatterns']),
    );
  }

  static PlanLocation? _parsePlanLocation(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PlanLocation(
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  static List<Itinerary>? _parseTripPatterns(List<dynamic>? patterns) {
    if (patterns == null) return null;
    return patterns
        .map((p) => _parseTripPattern(p as Map<String, dynamic>))
        .toList();
  }

  static Itinerary _parseTripPattern(Map<String, dynamic> json) {
    final legs = (json['legs'] as List<dynamic>?)
            ?.map((l) => _parseLeg(l as Map<String, dynamic>))
            .toList() ??
        [];

    final startTimeStr =
        json['expectedStartTime'] as String? ?? json['aimedStartTime'] as String?;
    final endTimeStr =
        json['expectedEndTime'] as String? ?? json['aimedEndTime'] as String?;

    return Itinerary(
      legs: legs,
      startTime:
          startTimeStr != null ? DateTime.parse(startTimeStr) : DateTime.now(),
      endTime: endTimeStr != null ? DateTime.parse(endTimeStr) : DateTime.now(),
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      walkDistance: (json['streetDistance'] as num?)?.toDouble() ?? 0,
      walkTime: Duration(seconds: json['walkTime'] as int? ?? 0),
    );
  }

  static ItineraryLeg _parseLeg(Map<String, dynamic> json) {
    final mode = json['mode'] as String? ?? 'WALK';
    final encodedPoints =
        json['pointsOnLink']?['points'] as String?;
    final decodedPoints = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    final line = json['line'] as Map<String, dynamic>?;
    final authority = json['authority'] as Map<String, dynamic>?;

    final startTimeStr =
        json['expectedStartTime'] as String? ?? json['aimedStartTime'] as String?;
    final endTimeStr =
        json['expectedEndTime'] as String? ?? json['aimedEndTime'] as String?;

    return ItineraryLeg(
      mode: _convertMode(mode),
      startTime:
          startTimeStr != null ? DateTime.parse(startTimeStr) : DateTime.now(),
      endTime: endTimeStr != null ? DateTime.parse(endTimeStr) : DateTime.now(),
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      transitLeg: json['ride'] as bool? ?? _isTransitMode(mode),
      encodedPoints: encodedPoints,
      decodedPoints: decodedPoints,
      route: line != null ? _parseRoute(line) : null,
      shortName: line?['publicCode'] as String?,
      routeLongName: line?['name'] as String? ?? '',
      agency: authority != null ? _parseAgency(authority) : null,
      fromPlace: _parsePlace(json['fromPlace']),
      toPlace: _parsePlace(json['toPlace']),
      intermediatePlaces: _parseIntermediatePlaces(json['intermediateQuays']),
      headsign: json['toEstimatedCall']?['destinationDisplay']?['frontText']
          as String?,
      interlineWithPreviousLeg:
          json['interchangeFrom']?['staySeated'] as bool?,
    );
  }

  static String _convertMode(String mode) {
    // Convert OTP 2.7 modes to standard OTP modes
    const modeMapping = {
      'foot': 'WALK',
      'bus': 'BUS',
      'rail': 'RAIL',
      'metro': 'SUBWAY',
      'tram': 'TRAM',
      'water': 'FERRY',
      'air': 'AIRPLANE',
      'coach': 'BUS',
      'bicycle': 'BICYCLE',
      'car': 'CAR',
      'funicular': 'FUNICULAR',
      'cableway': 'GONDOLA',
      'lift': 'CABLE_CAR',
    };
    return modeMapping[mode.toLowerCase()] ?? mode.toUpperCase();
  }

  static bool _isTransitMode(String mode) {
    const transitModes = {
      'BUS',
      'RAIL',
      'SUBWAY',
      'TRAM',
      'FERRY',
      'AIRPLANE',
      'FUNICULAR',
      'GONDOLA',
      'CABLE_CAR',
    };
    return transitModes.contains(mode.toUpperCase());
  }

  static Route _parseRoute(Map<String, dynamic> json) {
    final presentation = json['presentation'] as Map<String, dynamic>?;
    return Route(
      id: json['id'] as String?,
      shortName: json['publicCode'] as String?,
      longName: json['name'] as String?,
      color: presentation?['colour'] as String?,
      textColor: presentation?['textColour'] as String?,
    );
  }

  static Agency _parseAgency(Map<String, dynamic> json) {
    return Agency(
      gtfsId: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  static Place? _parsePlace(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Place(
      name: json['name'] as String? ?? '',
      lat: (json['latitude'] as num).toDouble(),
      lon: (json['longitude'] as num).toDouble(),
    );
  }

  static List<Place>? _parseIntermediatePlaces(List<dynamic>? places) {
    if (places == null) return null;
    return places.map((p) {
      final json = p as Map<String, dynamic>;
      return Place(
        name: json['name'] as String? ?? '',
        lat: (json['latitude'] as num).toDouble(),
        lon: (json['longitude'] as num).toDouble(),
        stopId: json['id'] as String?,
      );
    }).toList();
  }
}
