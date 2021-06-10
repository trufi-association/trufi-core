import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/place_entity.dart';
import 'package:trufi_core/entities/plan_entity/route_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/services/models_otp/pickup_booking_info.dart';

import 'agency_entity.dart';
import 'enum/leg_mode.dart';
import 'utils/modes_transport_utils.dart';
import 'utils/plan_itinerary_leg_utils.dart';
import 'utils/time_utils.dart';

part 'modes_transport_entity.dart';
part 'plan_error.dart';
part 'plan_itinerary.dart';
part 'plan_itinerary_leg.dart';
part 'plan_location.dart';

class PlanEntity {
  PlanEntity({
    this.from,
    this.to,
    this.itineraries,
    this.error,
  });

  static const _error = "error";
  static const _itineraries = "itineraries";
  static const _from = "from";
  static const _plan = "plan";
  static const _to = "to";

  final PlanLocation from;
  final PlanLocation to;
  final List<PlanItinerary> itineraries;
  final PlanError error;

  factory PlanEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.containsKey(_error)) {
      return PlanEntity(
          error: PlanError.fromJson(json[_error] as Map<String, dynamic>));
    } else {
      final Map<String, dynamic> planJson = json[_plan] as Map<String, dynamic>;
      return PlanEntity(
        from: PlanLocation.fromJson(planJson[_from] as Map<String, dynamic>),
        to: PlanLocation.fromJson(planJson[_to] as Map<String, dynamic>),
        itineraries: removePlanItineraryDuplicates(
          planJson[_itineraries]
              .map<PlanItinerary>(
                (dynamic itineraryJson) => PlanItinerary.fromJson(
                    itineraryJson as Map<String, dynamic>),
              )
              .toList() as List<PlanItinerary>,
        ),
      );
    }
  }

  PlanEntity copyWith({
    PlanLocation from,
    PlanLocation to,
    List<PlanItinerary> itineraries,
    PlanError error,
  }) {
    return PlanEntity(
      from: from ?? this.from,
      to: to ?? this.to,
      itineraries: itineraries ?? this.itineraries,
      error: error ?? this.error,
    );
  }

  static List<PlanItinerary> removePlanItineraryDuplicates(
    List<PlanItinerary> itineraries,
  ) {
    final usedRoutes = <String>{};
    // Fold the itinerary list to build up list without duplicates
    return itineraries.fold<List<PlanItinerary>>(
      <PlanItinerary>[],
      (itineraries, itinerary) {
        // Get first bus leg
        final firstBusLeg = itinerary.legs.firstWhere(
          (leg) => leg.mode == "BUS",
          orElse: () => null,
        );
        // If no bus leg exist just add the itinerary
        if (firstBusLeg == null) {
          itineraries.add(itinerary);
        } else {
          // If a bus leg exist and the first route isn't used yet just add the itinerary
          final startTime = firstBusLeg.startTime?.millisecondsSinceEpoch ?? 0;
          final endTime = firstBusLeg.endTime?.millisecondsSinceEpoch ?? 0;
          if (!usedRoutes.contains('${firstBusLeg.route}$startTime$endTime')) {
            itineraries.add(itinerary);
            usedRoutes.add('${firstBusLeg.route}$startTime$endTime');
          }
        }
        // Return current list
        return itineraries;
      },
    );
  }

  factory PlanEntity.fromError(String error) {
    return PlanEntity(error: PlanError.fromError(error));
  }

  Map<String, dynamic> toJson() {
    return error != null
        ? {_error: error.toJson()}
        : {
            _plan: {
              _from: from.toJson(),
              _to: to.toJson(),
              _itineraries:
                  itineraries.map((itinerary) => itinerary.toJson()).toList()
            }
          };
  }

  bool get hasError => error != null;
}
