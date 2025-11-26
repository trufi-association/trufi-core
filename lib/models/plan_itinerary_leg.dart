part of 'plan_entity.dart';

class PlanItineraryLeg {
  PlanItineraryLeg({
    required this.points,
    required this.mode,
    this.route,
    this.shortName,
    required this.routeLongName,
    required this.distance,
    required this.duration,
    this.agency,
    this.realtimeState,
    this.toPlace,
    this.fromPlace,
    required this.startTime,
    required this.endTime,
    this.steps,
    this.intermediatePlaces,
    this.intermediatePlace,
    required this.transitLeg,
    this.rentedBike,
    this.pickupBookingInfo,
    this.dropOffBookingInfo,
    this.interlineWithPreviousLeg,
    this.accumulatedPoints = const [],
    this.trip,
  }) : selectedMarker = TrufiMarker(
         id: "$shortName",
         position: accumulatedPoints[(accumulatedPoints.length / 2).floor()],
         widget: Container(
           padding: const EdgeInsets.all(4.0),
           decoration: BoxDecoration(
             color: hexToColor(route?.color ?? 'd81b60'),
             borderRadius: const BorderRadius.all(Radius.circular(4.0)),
           ),
           child: FittedBox(
             fit: BoxFit.scaleDown,
             child: Row(
               children: [
                 SizedBox(
                   height: 28,
                   width: 28,
                   child: getTransportMode(
                     mode: mode,
                     specificTransport: routeLongName,
                   ).getImage(color: Colors.white),
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 4),
                   child: Text(
                     route?.shortName ?? 'no name',
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 17,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
         size: Size(60, 30),
         layerLevel: 2,
       ),
       unSelectedMarker = TrufiMarker(
         id: "${shortName}",
         position: accumulatedPoints[(accumulatedPoints.length / 2).floor()],
         widget: Container(
           padding: const EdgeInsets.all(4.0),
           decoration: BoxDecoration(
             color: Colors.grey,
             borderRadius: const BorderRadius.all(Radius.circular(4.0)),
           ),
           child: FittedBox(
             fit: BoxFit.scaleDown,
             child: Row(
               children: [
                 SizedBox(
                   height: 28,
                   width: 28,
                   child: getTransportMode(
                     mode: mode,
                     specificTransport: routeLongName,
                   ).getImage(color: Colors.white),
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 4),
                   child: Text(
                     route?.shortName ?? 'no name',
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 17,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
         size: Size(60, 30),
         layerLevel: 1,
       ) {
    transportMode = getTransportMode(
      mode: mode,
      specificTransport: routeLongName,
    );
  }

  static const String _points = 'points';
  static const String _mode = 'mode';
  static const String _route = 'route';
  static const String _routeLongName = 'routeLongName';
  static const String _distance = 'distance';
  static const String _duration = 'duration';
  static const String _legGeometry = "legGeometry";
  static const String _agency = 'agency';
  static const String _realtimeState = 'realtimeState';
  static const String _toPlace = 'toPlace';
  static const String _fromPlace = 'fromPlace';
  static const String _startTime = 'startTime';
  static const String _endTime = 'endTime';
  static const String _transitLeg = 'transitLeg';
  static const String _intermediatePlace = 'intermediatePlace';
  static const String _rentedBike = 'rentedBike';
  static const String _interlineWithPreviousLeg = 'interlineWithPreviousLeg';
  static const String _pickupBookingInfo = 'pickupBookingInfo';
  static const String _dropOffBookingInfo = 'dropOffBookingInfo';
  static const String _steps = 'steps';
  static const String _intermediatePlaces = 'intermediatePlaces';
  static const String _trip = 'trip';

  final String points;
  final String mode;
  final RouteEntity? route;
  final String? shortName;
  final String routeLongName;
  final double distance;
  final Duration duration;
  final AgencyEntity? agency;
  final RealtimeStateTrufi? realtimeState;
  final PlaceEntity? toPlace;
  final PlaceEntity? fromPlace;
  final DateTime startTime;
  final DateTime endTime;
  final bool transitLeg;
  final bool? intermediatePlace;
  final bool? rentedBike;
  final bool? interlineWithPreviousLeg;
  final PickupBookingInfoEntity? pickupBookingInfo;
  final BookingInfoEntity? dropOffBookingInfo;
  final List<StepEntity>? steps;
  final List<PlaceEntity>? intermediatePlaces;
  final TripEntity? trip;

  late TransportMode transportMode;
  final List<LatLng> accumulatedPoints;
  final TrufiMarker selectedMarker;
  final TrufiMarker unSelectedMarker;

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return PlanItineraryLeg(
      points: json[_legGeometry][_points],
      mode: json[_mode],
      route: json[_route] != null
          ? ((json[_route] is Map<String, dynamic>)
                ? RouteEntity.fromJson(json[_route] as Map<String, dynamic>)
                : null)
          : null,
      shortName: json[_route] != null
          ? ((json[_route] is String) && json[_route] != ''
                ? json[_route]
                : null)
          : null,
      routeLongName: json[_routeLongName],
      distance: json[_distance],
      duration: Duration(seconds: json[_duration]),
      agency: json[_agency] != null
          ? AgencyEntity.fromJson(json[_agency] as Map<String, dynamic>)
          : null,
      realtimeState: getRealtimeStateByString(json[_realtimeState]),
      toPlace: json[_toPlace] != null
          ? PlaceEntity.fromJson(json[_toPlace] as Map<String, dynamic>)
          : null,
      fromPlace: json[_fromPlace] != null
          ? PlaceEntity.fromJson(json[_fromPlace] as Map<String, dynamic>)
          : null,
      startTime: DateTime.fromMillisecondsSinceEpoch(json[_startTime]),
      endTime: DateTime.fromMillisecondsSinceEpoch(json[_endTime]),
      steps: json[_steps] != null
          ? List<StepEntity>.from(
              (json[_steps] as List<dynamic>).map(
                (x) => StepEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      intermediatePlaces: json[_intermediatePlaces] != null
          ? List<PlaceEntity>.from(
              (json[_intermediatePlaces] as List<dynamic>).map(
                (x) => PlaceEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      pickupBookingInfo: json[_pickupBookingInfo] != null
          ? PickupBookingInfoEntity.fromJson(
              json[_pickupBookingInfo] as Map<String, dynamic>,
            )
          : null,
      dropOffBookingInfo: json[_dropOffBookingInfo] != null
          ? BookingInfoEntity.fromJson(
              json[_dropOffBookingInfo] as Map<String, dynamic>,
            )
          : null,
      transitLeg: json[_transitLeg],
      intermediatePlace: json[_intermediatePlace],
      rentedBike: json[_rentedBike],
      interlineWithPreviousLeg: json[_interlineWithPreviousLeg],
      accumulatedPoints: TrufiMapUtils.decodePolyline(
        json[_legGeometry][_points],
      ),
      trip: json[_trip] != null
          ? TripEntity.fromJson(json[_trip] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _legGeometry: {_points: points},
      _mode: mode,
      _route: route?.toJson() ?? shortName,
      _routeLongName: routeLongName,
      _distance: distance,
      _duration: duration.inSeconds,
      _agency: agency?.toJson(),
      _realtimeState: realtimeState?.name,
      _toPlace: toPlace?.toJson(),
      _fromPlace: fromPlace?.toJson(),
      _startTime: startTime.millisecondsSinceEpoch,
      _endTime: endTime.millisecondsSinceEpoch,
      _steps: steps != null
          ? List<dynamic>.from(steps!.map((x) => x.toMap()))
          : null,
      _intermediatePlaces: intermediatePlaces != null
          ? List<dynamic>.from(intermediatePlaces!.map((x) => x.toJson()))
          : null,
      _pickupBookingInfo: pickupBookingInfo?.toJson(),
      _dropOffBookingInfo: dropOffBookingInfo?.toJson(),
      _intermediatePlace: intermediatePlace,
      _transitLeg: transitLeg,
      _rentedBike: rentedBike,
      _interlineWithPreviousLeg: interlineWithPreviousLeg,
      _trip: trip?.toJson(),
    };
  }
}
