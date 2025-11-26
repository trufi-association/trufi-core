import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/models/alert.dart';
import 'package:trufi_core/models/booking_info.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/enums/realtime_state.dart';
import 'package:trufi_core/models/enums/vertex_type.dart';
import 'package:trufi_core/models/vehicle_parking_with_entrance.dart';
import 'package:trufi_core/models/pickup_booking_info.dart';
import 'package:trufi_core/models/step_entity.dart';
import 'package:trufi_core/models/trip.dart';
import 'package:trufi_core/models/trufi_map_utils.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/utils.dart';
import 'package:collection/collection.dart';


part 'bike_park_entity.dart';
part 'stop_entity.dart';
part 'bike_rental_station_entity.dart';
part 'place_entity.dart';
part 'car_park_entity.dart';
part 'route_entity.dart';
part 'agency_entity.dart';
part 'plan_itinerary.dart';
part 'plan_itinerary_leg.dart';
part 'plan_location.dart';

class PlanEntity {
  const PlanEntity({this.type, this.from, this.to, this.itineraries});

  static const String _from = 'from';
  static const String _to = 'to';
  static const String _type = 'type';
  static const String _itineraries = 'itineraries';

  final PlanLocation? from;
  final PlanLocation? to;
  final String? type;
  final List<PlanItinerary>? itineraries;

  factory PlanEntity.fromJson(Map<String, dynamic> json) {
    return PlanEntity(
      from: PlanLocation.fromJson(json[_from]),
      to: PlanLocation.fromJson(json[_to]),
      itineraries:
          json[_itineraries]
                  .map<PlanItinerary>(
                    (dynamic itineraryJson) =>
                        PlanItinerary.fromJson(itineraryJson),
                  )
                  .toList()
              as List<PlanItinerary>,
      type: json[_type],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _from: from?.toJson(),
      _to: to?.toJson(),
      _itineraries:
          itineraries?.map((itinerary) => itinerary.toJson()).toList(),
      _type: type,
    };
  }

  PlanEntity copyWith({
    PlanLocation? from,
    PlanLocation? to,
    List<PlanItinerary>? itineraries,
    String? type,
  }) {
    return PlanEntity(
      from: from ?? this.from,
      to: to ?? this.to,
      itineraries: itineraries ?? this.itineraries,
      type: type ?? this.type,
    );
  }
}
