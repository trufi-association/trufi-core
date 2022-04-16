import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';

import 'utils/leg_utils.dart';
import 'utils/duration_utils.dart';

part 'itinerary.dart';
part 'leg.dart';
part 'place.dart';
part 'transport_route.dart';
part 'plan_error.dart';

class Plan extends Equatable {
  static List<Itinerary> removePlanItineraryDuplicates(
    List<Itinerary> itineraries,
  ) {
    final usedRoutes = <String>{};
    // Fold the itinerary list to build up list without duplicates
    return itineraries.fold<List<Itinerary>>(
      <Itinerary>[],
      (itineraries, itinerary) {
        // Get first bus leg
        final firstBusLeg =
            itinerary.legs.firstWhereOrNull((leg) => leg.transitLeg);
        // If no bus leg exist just add the itinerary
        if (firstBusLeg == null) {
          itineraries.add(itinerary);
        } else {
          // If a bus leg exist and the first route isn't used yet just add the itinerary
          if (!usedRoutes.contains(firstBusLeg.shortName)) {
            itineraries.add(itinerary);
            usedRoutes.add(firstBusLeg.shortName!);
          }
        }
        // Return current list
        return itineraries;
      },
    );
  }

  static const _itineraries = "itineraries";
  static const _plan = "plan";
  static const _error = "error";

  final List<Itinerary>? itineraries;
  final PlanError? error;

  const Plan({
    this.itineraries,
    this.error,
  });

  Plan copyWith({
    List<Itinerary>? itineraries,
  }) {
    return Plan(
      itineraries: itineraries ?? this.itineraries,
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json.containsKey(_error)) {
      return Plan(
          error: PlanError.fromJson(json[_error] as Map<String, dynamic>));
    } else {
      final Map<String, dynamic> planJson = json[_plan] as Map<String, dynamic>;
      return Plan(
        itineraries: removePlanItineraryDuplicates(planJson[_itineraries]
                ?.map<Itinerary>((dynamic itineraryJson) =>
                    Itinerary.fromJson(itineraryJson as Map<String, dynamic>))
                .toList() as List<Itinerary>? ??
            []),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return error != null
        ? {
            _error: error?.toJson(),
          }
        : {
            _plan: {
              _itineraries:
                  itineraries?.map((itinerary) => itinerary.toJson()).toList(),
            },
          };
  }

  bool get isOnlyWalk =>
      itineraries != null && itineraries!.isEmpty ||
      itineraries!.length == 1 &&
          itineraries![0].legs.length == 1 &&
          itineraries![0].legs[0].transportMode == TransportMode.walk;

  bool get hasError => error != null;
  
  @override
  List<Object?> get props => [
        itineraries,
        error,
      ];
}
