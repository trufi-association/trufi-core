import 'package:trufi_core/models/plan_entity.dart';
import 'pickup_dropoff_type.dart';
import 'enums/realtime_state.dart';
import 'trip.dart';

class Stoptime {
  final StopEntity? stop;
  final int? scheduledArrival;
  final int? realtimeArrival;
  final int? arrivalDelay;
  final int? scheduledDeparture;
  final int? realtimeDeparture;
  final int? departureDelay;
  final bool? timepoint;
  final bool? realtime;
  final RealtimeStateTrufi? realtimeState;
  final PickupDropoffType? pickupType;
  final PickupDropoffType? dropoffType;
  final double? serviceDay;
  final TripEntity? trip;
  final String? headsign;

  const Stoptime({
    this.stop,
    this.scheduledArrival,
    this.realtimeArrival,
    this.arrivalDelay,
    this.scheduledDeparture,
    this.realtimeDeparture,
    this.departureDelay,
    this.timepoint,
    this.realtime,
    this.realtimeState,
    this.pickupType,
    this.dropoffType,
    this.serviceDay,
    this.trip,
    this.headsign,
  });

  static const String _stop = 'stop';
  static const String _scheduledArrival = 'scheduledArrival';
  static const String _realtimeArrival = 'realtimeArrival';
  static const String _arrivalDelay = 'arrivalDelay';
  static const String _scheduledDeparture = 'scheduledDeparture';
  static const String _realtimeDeparture = 'realtimeDeparture';
  static const String _departureDelay = 'departureDelay';
  static const String _timepoint = 'timepoint';
  static const String _realtime = 'realtime';
  static const String _realtimeState = 'realtimeState';
  static const String _pickupType = 'pickupType';
  static const String _dropoffType = 'dropoffType';
  static const String _serviceDay = 'serviceDay';
  static const String _trip = 'trip';
  static const String _headsign = 'headsign';

  factory Stoptime.fromJson(Map<String, dynamic> json) => Stoptime(
    stop:
        json[_stop] != null
            ? StopEntity.fromJson(json[_stop] as Map<String, dynamic>)
            : null,
    scheduledArrival: json[_scheduledArrival],
    realtimeArrival: json[_realtimeArrival],
    arrivalDelay: json[_arrivalDelay],
    scheduledDeparture: json[_scheduledDeparture],
    realtimeDeparture: json[_realtimeDeparture],
    departureDelay: json[_departureDelay],
    timepoint: json[_timepoint],
    realtime: json[_realtime],
    realtimeState: getRealtimeStateByString(json[_realtimeState]),
    pickupType: getPickupDropoffTypeByString(json[_pickupType]),
    dropoffType: getPickupDropoffTypeByString(json[_dropoffType]),
    serviceDay: json[_serviceDay],
    trip:
        json[_trip] != null
            ? TripEntity.fromJson(json[_trip] as Map<String, dynamic>)
            : null,
    headsign: json[_headsign],
  );

  Map<String, dynamic> toJson() => {
    _stop: stop?.toJson(),
    _scheduledArrival: scheduledArrival,
    _realtimeArrival: realtimeArrival,
    _arrivalDelay: arrivalDelay,
    _scheduledDeparture: scheduledDeparture,
    _realtimeDeparture: realtimeDeparture,
    _departureDelay: departureDelay,
    _timepoint: timepoint,
    _realtime: realtime,
    _realtimeState: realtimeState?.name,
    _pickupType: pickupType?.name,
    _dropoffType: dropoffType?.name,
    _serviceDay: serviceDay,
    _trip: trip?.toJson(),
    _headsign: headsign,
  };
}
