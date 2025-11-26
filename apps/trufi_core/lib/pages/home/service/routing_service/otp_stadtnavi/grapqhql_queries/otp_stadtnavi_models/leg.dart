import 'package:trufi_core/models/plan_entity.dart' as dsadsad;
import 'package:trufi_core/models/trufi_map_utils.dart';
import 'agency.dart';
import 'alert.dart';
import 'booking_info.dart';
import 'enums/pickup_dropoff_type.dart';
import 'enums/realtime_state.dart';
import 'enums/mode.dart';
import 'geometry.dart';
import 'pickup_booking_info.dart';
import 'place.dart';
import 'route.dart';
import 'step.dart';
import 'stop.dart';
import 'trip.dart';

class Leg {
  final int? startTime;
  final int? endTime;
  final int? departureDelay;
  final int? arrivalDelay;
  final Mode? mode;
  final double? duration;
  final int? generalizedCost;
  final Geometry? legGeometry;
  final Agency? agency;
  final bool? realTime;
  final RealtimeState? realtimeState;
  final double? distance;
  final bool? transitLeg;
  final bool? rentedBike;
  final Place? from;
  final Place? to;
  final RouteOtp? route;
  final Trip? trip;
  final String? serviceDate;
  final List<Stop>? intermediateStops;
  final List<Place>? intermediatePlaces;
  final bool? intermediatePlace;
  final List<Step>? steps;
  final PickupDropoffType? pickupType;
  final PickupDropoffType? dropoffType;
  final bool? interlineWithPreviousLeg;
  final List<Alert>? alerts;
  final PickupBookingInfo? pickupBookingInfo;
  final BookingInfo? dropOffBookingInfo;

  const Leg({
    this.startTime,
    this.endTime,
    this.departureDelay,
    this.arrivalDelay,
    this.mode,
    this.duration,
    this.generalizedCost,
    this.legGeometry,
    this.agency,
    this.realTime,
    this.realtimeState,
    this.distance,
    this.transitLeg,
    this.rentedBike,
    this.from,
    this.to,
    this.route,
    this.trip,
    this.serviceDate,
    this.intermediateStops,
    this.intermediatePlaces,
    this.intermediatePlace,
    this.steps,
    this.pickupType,
    this.dropoffType,
    this.interlineWithPreviousLeg,
    this.alerts,
    this.pickupBookingInfo,
    this.dropOffBookingInfo,
  });

  factory Leg.fromMap(Map<String, dynamic> json) => Leg(
    startTime: int.tryParse(json['startTime'].toString()),
    endTime: int.tryParse(json['endTime'].toString()),
    departureDelay: int.tryParse(json['departureDelay'].toString()),
    arrivalDelay: int.tryParse(json['arrivalDelay'].toString()),
    mode: getModeByString(json['mode']),
    duration: double.tryParse(json['duration'].toString()),
    generalizedCost: int.tryParse(json['generalizedCost'].toString()),
    legGeometry: json['legGeometry'] != null
        ? Geometry.fromJson(json['legGeometry'] as Map<String, dynamic>)
        : null,
    agency: json['agency'] != null
        ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
        : null,
    realTime: json['realTime'] as bool?,
    realtimeState: getRealtimeStateByString(json['realtimeState'].toString()),
    distance: double.tryParse(json['distance'].toString()),
    transitLeg: json['transitLeg'] as bool?,
    rentedBike: json['rentedBike'] as bool?,
    from: json['from'] != null
        ? Place.fromMap(json['from'] as Map<String, dynamic>)
        : null,
    to: json['to'] != null
        ? Place.fromMap(json['to'] as Map<String, dynamic>)
        : null,
    route: json['route'] != null
        ? RouteOtp.fromJson(json['route'] as Map<String, dynamic>)
        : null,
    trip: json['trip'] != null
        ? Trip.fromJson(json['trip'] as Map<String, dynamic>)
        : null,
    serviceDate: json['serviceDate'].toString(),
    intermediateStops: json['intermediateStops'] != null
        ? List<Stop>.from(
            (json["intermediateStops"] as List<dynamic>).map(
              (x) => Stop.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    intermediatePlaces: json['intermediatePlaces'] != null
        ? List<Place>.from(
            (json["intermediatePlaces"] as List<dynamic>).map(
              (x) => Place.fromMap(x as Map<String, dynamic>),
            ),
          )
        : null,
    intermediatePlace: json['intermediatePlace'] as bool?,
    steps: json['steps'] != null
        ? List<Step>.from(
            (json["steps"] as List<dynamic>).map(
              (x) => Step.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    pickupType: getPickupDropoffTypeByString(json['pickupType'].toString()),
    dropoffType: getPickupDropoffTypeByString(json['dropoffType'].toString()),
    interlineWithPreviousLeg: json['interlineWithPreviousLeg'] as bool?,
    alerts: json['alerts'] != null
        ? List<Alert>.from(
            (json["alerts"] as List<dynamic>).map(
              (x) => Alert.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    pickupBookingInfo: json['pickupBookingInfo'] != null
        ? PickupBookingInfo.fromMap(
            json['pickupBookingInfo'] as Map<String, dynamic>,
          )
        : null,
    dropOffBookingInfo: json['dropOffBookingInfo'] != null
        ? BookingInfo.fromMap(
            json['dropOffBookingInfo'] as Map<String, dynamic>,
          )
        : null,
  );

  Map<String, dynamic> toMap() => {
    'startTime': startTime,
    'endTime': endTime,
    'departureDelay': departureDelay,
    'arrivalDelay': arrivalDelay,
    'mode': mode?.name,
    'duration': duration,
    'generalizedCost': generalizedCost,
    'legGeometry': legGeometry?.toJson(),
    'agency': agency?.toJson(),
    'realTime': realTime,
    'realtimeState': realtimeState?.name,
    'distance': distance,
    'transitLeg': transitLeg,
    'rentedBike': rentedBike,
    'from': from?.toMap(),
    'to': to?.toMap(),
    'route': route?.toJson(),
    'trip': trip?.toJson(),
    'serviceDate': serviceDate,
    'intermediateStops': intermediateStops != null
        ? List<dynamic>.from(intermediateStops!.map((x) => x.toJson()))
        : null,
    'intermediatePlaces': intermediatePlaces != null
        ? List<dynamic>.from(intermediatePlaces!.map((x) => x.toMap()))
        : null,
    'intermediatePlace': intermediatePlace,
    'steps': steps != null
        ? List<dynamic>.from(steps!.map((x) => x.toJson()))
        : null,
    'pickupType': pickupType?.name,
    'dropoffType': dropoffType?.name,
    'interlineWithPreviousLeg': interlineWithPreviousLeg,
    'alerts': alerts != null
        ? List<dynamic>.from(alerts!.map((x) => x.toJson()))
        : null,
    'pickupBookingInfo': pickupBookingInfo?.toMap(),
    'dropOffBookingInfo': dropOffBookingInfo?.toMap(),
  };

  dsadsad.PlanItineraryLeg toPlanItineraryLeg() {
    return dsadsad.PlanItineraryLeg(
      points: legGeometry?.points ?? '',
      mode: mode?.toOtpString() ?? '',
      route: route?.toRouteEntity(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime ?? 0),
      distance: distance ?? 0,
      duration: Duration(seconds: (duration ?? 0).toInt()),
      routeLongName: route?.longName ?? '',
      agency: agency?.toAgencyEntity(),
      realtimeState: realtimeState?.toRealtimeState(),
      toPlace: to?.toPlaceEntity(),
      fromPlace: from?.toPlaceEntity(),
      steps: steps?.map((x) => x.toStepEntity()).toList(),
      intermediatePlaces: intermediatePlaces
          ?.map((x) => x.toPlaceEntity())
          .toList(),
      pickupBookingInfo: pickupBookingInfo?.toPickupBookingInfoEntity(),
      dropOffBookingInfo: dropOffBookingInfo?.toBookingInfoEntity(),
      rentedBike: rentedBike,
      intermediatePlace: intermediatePlace,
      transitLeg: transitLeg ?? false,
      interlineWithPreviousLeg: interlineWithPreviousLeg,
      accumulatedPoints: legGeometry?.points != null
          ? TrufiMapUtils.decodePolyline(legGeometry?.points)
          : [],
      trip: trip?.toTripEntity(),
    );
  }
}
