import 'package:intl/intl.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'leg_ui.dart';

/// UI extensions for [Itinerary] from trufi_core_routing package.
extension ItineraryUI on Itinerary {
  /// Start time formatted as HH:mm.
  String get startTimeHHmm => DateFormat('HH:mm').format(startTime);

  /// End time formatted as HH:mm.
  String get endTimeHHmm => DateFormat('HH:mm').format(endTime);

  /// Compress consecutive walk/bike legs into single legs.
  List<Leg> get compressLegs {
    final compressedLegs = <Leg>[];
    Leg? compressedLeg;

    for (final currentLeg in legs) {
      if (compressedLeg == null) {
        compressedLeg = currentLeg.copyWith();
        continue;
      }

      if (LegUtils.canCombineLegs(compressedLeg, currentLeg)) {
        compressedLeg = compressedLeg.copyWith(
          duration: compressedLeg.duration + currentLeg.duration,
          distance: compressedLeg.distance + currentLeg.distance,
          toPlace: currentLeg.toPlace,
          endTime: currentLeg.endTime,
          mode: TransportMode.bicycle.otpName,
          decodedPoints: [
            ...compressedLeg.decodedPoints,
            ...currentLeg.decodedPoints,
          ],
        );
        continue;
      }

      compressedLegs.add(compressedLeg);
      compressedLeg = currentLeg.copyWith();
    }

    if (compressedLeg != null) {
      compressedLegs.add(compressedLeg);
    }

    return compressedLegs;
  }

  /// Returns the first departure (transit) leg.
  Leg? get getFirstDeparture {
    return compressLegs.cast<Leg?>().firstWhere(
          (leg) => leg?.transitLeg ?? false,
          orElse: () => null,
        );
  }

  /// Total biking distance.
  double get totalBikingDistance =>
      LegUtils.getTotalBikingDistance(compressLegs);

  /// Total biking duration.
  Duration get totalBikingDuration =>
      LegUtils.getTotalBikingDuration(compressLegs);

  /// Count of legs that are hidden at a given threshold.
  int getNumberLegHide(double renderBarThreshold) {
    return compressLegs
        .where((leg) {
          final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
          return legLength < renderBarThreshold &&
              leg.transportMode != TransportMode.walk;
        })
        .toList()
        .length;
  }

  /// Total time of legs hidden at a given threshold.
  int getNumberLegTime(double renderBarThreshold) {
    return compressLegs.fold(0, (previousValue, leg) {
      final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
      return legLength < renderBarThreshold
          ? previousValue + leg.duration.inSeconds
          : previousValue;
    });
  }
}

/// Utility functions for working with plans.
class PlanUtils {
  PlanUtils._();

  /// Remove duplicate itineraries based on first bus route.
  static List<Itinerary> removeDuplicates(List<Itinerary> itineraries) {
    final usedRoutes = <String>{};
    return itineraries.fold<List<Itinerary>>(
      <Itinerary>[],
      (result, itinerary) {
        final firstBusLeg = itinerary.legs.cast<Leg?>().firstWhere(
              (leg) => leg?.transitLeg ?? false,
              orElse: () => null,
            );
        if (firstBusLeg == null) {
          result.add(itinerary);
        } else {
          if (!usedRoutes.contains(firstBusLeg.shortName)) {
            result.add(itinerary);
            if (firstBusLeg.shortName != null) {
              usedRoutes.add(firstBusLeg.shortName!);
            }
          }
        }
        return result;
      },
    );
  }
}
