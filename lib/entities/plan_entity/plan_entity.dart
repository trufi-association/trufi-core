import 'package:flutter/material.dart';

import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/plan_enums.dart';

part 'plan_location.dart';
part 'plan_error.dart';
part 'plan_itinerary.dart';
part 'plan_itinerary_leg.dart';

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
                (dynamic itineraryJson) =>
                    PlanItinerary.fromJson(itineraryJson as Map<String, dynamic>),
              )
              .toList() as List<PlanItinerary>,
        ),
      );
    }
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
          if (!usedRoutes.contains(firstBusLeg.route)) {
            itineraries.add(itinerary);
            usedRoutes.add(firstBusLeg.route);
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
