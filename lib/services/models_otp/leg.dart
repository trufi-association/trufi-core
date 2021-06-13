import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/widgets/map/utils/trufi_map_utils.dart';

import 'agency.dart';
import 'alert.dart';
import 'enums/leg/pickup_dropoff_type.dart';
import 'enums/leg/realtime_state.dart';
import 'enums/mode.dart';
import 'geometry.dart';
import 'pickup_booking_info.dart';
import 'place.dart';
import 'route.dart';
import 'step.dart';
import 'stop.dart';
import 'trip.dart';

class Leg {
  final int startTime;
  final int endTime;
  final int departureDelay;
  final int arrivalDelay;
  final Mode mode;
  final double duration;
  final int generalizedCost;
  final Geometry legGeometry;
  final Agency agency;
  final bool realTime;
  final RealtimeState realtimeState;
  final double distance;
  final bool transitLeg;
  final bool rentedBike;
  final Place from;
  final Place to;
  final RouteOtp route;
  final Trip trip;
  final String serviceDate;
  final List<Stop> intermediateStops;
  final List<Place> intermediatePlaces;
  final bool intermediatePlace;
  final List<Step> steps;
  final PickupDropoffType pickupType;
  final PickupDropoffType dropoffType;
  final bool interlineWithPreviousLeg;
  final List<Alert> alerts;
  final PickupBookingInfo pickupBookingInfo;

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
  });

  factory Leg.fromMap(Map<String, dynamic> json) => Leg(
        startTime: int.tryParse(json['startTime'].toString()),
        endTime: int.tryParse(json['endTime'].toString()),
        departureDelay: int.tryParse(json['departureDelay'].toString()),
        arrivalDelay: int.tryParse(json['arrivalDelay'].toString()),
        mode: getModeByString(json['mode'].toString()),
        duration: double.tryParse(json['duration'].toString()),
        generalizedCost: int.tryParse(json['generalizedCost'].toString()),
        legGeometry: json['legGeometry'] != null
            ? Geometry.fromJson(json['legGeometry'] as Map<String, dynamic>)
            : null,
        agency: json['agency'] != null
            ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
            : null,
        realTime: json['realTime'] as bool,
        realtimeState:
            getRealtimeStateByString(json['realtimeState'].toString()),
        distance: double.tryParse(json['distance'].toString()),
        transitLeg: json['transitLeg'] as bool,
        rentedBike: json['rentedBike'] as bool,
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
            ? List<Stop>.from((json["intermediateStops"] as List<dynamic>).map(
                (x) => Stop.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        intermediatePlaces: json['intermediatePlaces'] != null
            ? List<Place>.from(
                (json["intermediatePlaces"] as List<dynamic>).map(
                (x) => Place.fromMap(x as Map<String, dynamic>),
              ))
            : null,
        intermediatePlace: json['intermediatePlace'] as bool,
        steps: json['steps'] != null
            ? List<Step>.from((json["steps"] as List<dynamic>).map(
                (x) => Step.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        pickupType: getPickupDropoffTypeByString(json['pickupType'].toString()),
        dropoffType:
            getPickupDropoffTypeByString(json['dropoffType'].toString()),
        interlineWithPreviousLeg: json['interlineWithPreviousLeg'] as bool,
        alerts: json['alerts'] != null
            ? List<Alert>.from((json["alerts"] as List<dynamic>).map(
                (x) => Alert.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        pickupBookingInfo: json['pickupBookingInfo'] != null
            ? PickupBookingInfo.fromMap(
                json['pickupBookingInfo'] as Map<String, dynamic>)
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
            ? List<dynamic>.from(intermediateStops.map((x) => x.toJson()))
            : null,
        'intermediatePlaces': intermediatePlaces != null
            ? List<dynamic>.from(intermediatePlaces.map((x) => x.toMap()))
            : null,
        'intermediatePlace': intermediatePlace,
        'steps': List<dynamic>.from(steps.map((x) => x.toJson())),
        'pickupType': pickupType?.name,
        'dropoffType': dropoffType?.name,
        'interlineWithPreviousLeg': interlineWithPreviousLeg,
        'alerts': List<dynamic>.from(alerts.map((x) => x.toJson())),
        'pickupBookingInfo': pickupBookingInfo?.toMap(),
      };

  PlanItineraryLeg toPlanItineraryLeg() {
    return PlanItineraryLeg(
      points: legGeometry?.points,
      mode: mode?.name,
      route: route?.toRouteEntity(),
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : null,
      endTime:
          endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime) : null,
      distance: distance ?? 0,
      duration: duration ?? 0,
      routeLongName: route?.longName ?? '',
      agency: agency?.toAgencyEntity(),
      toPlace: to?.toPlaceEntity(),
      fromPlace: from?.toPlaceEntity(),
      intermediatePlaces:
          intermediatePlaces?.map((x) => x.toPlaceEntity())?.toList(),
      pickupBookingInfo: pickupBookingInfo,
      rentedBike: rentedBike,
      intermediatePlace: intermediatePlace,
      transitLeg: transitLeg,
      interlineWithPreviousLeg: interlineWithPreviousLeg,
      accumulatedPoints: legGeometry?.points != null
          ? decodePolyline(legGeometry?.points)
          : [],
    );
  }
}
