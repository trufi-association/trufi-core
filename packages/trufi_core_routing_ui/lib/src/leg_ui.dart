import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'transport_mode_ui.dart';

/// UI extensions for [Leg] from trufi_core_routing package.
extension LegUI on Leg {
  /// Foreground color for this leg's transport mode.
  Color get primaryColor => transportMode.color;

  /// Background color for this leg (route color or transport mode default).
  Color get backgroundColor {
    final codeColor = int.tryParse('0xFF${route?.color ?? routeColor}');
    return codeColor != null ? Color(codeColor) : transportMode.backgroundColor;
  }

  /// Display name for this leg (route short name, headsign, etc.).
  String get headSign {
    return route?.shortName ?? (route?.longName ?? (shortName ?? ''));
  }

  /// Start time formatted as HH:mm.
  String get startTimeString => DateFormat('HH:mm').format(startTime);

  /// End time formatted as HH:mm.
  String get endTimeString => DateFormat('HH:mm').format(endTime);
}

/// Utility functions for working with legs.
class LegUtils {
  LegUtils._();

  /// Returns true if two legs can be combined (both are walk/bike).
  static bool canCombineLegs(Leg leg1, Leg leg2) {
    final bool isOnFoot1 = leg1.transportMode == TransportMode.bicycle ||
        leg1.transportMode == TransportMode.walk;
    final bool isOnFoot2 = leg2.transportMode == TransportMode.bicycle ||
        leg2.transportMode == TransportMode.walk;
    return isOnFoot1 && isOnFoot2;
  }

  /// Returns true if this is a walking leg.
  static bool isWalkingLeg(Leg leg) {
    return leg.transportMode == TransportMode.walk;
  }

  /// Returns true if this is a biking leg.
  static bool isBikingLeg(Leg leg) {
    return leg.transportMode == TransportMode.bicycle;
  }

  /// Sum of distances for a list of legs.
  static double sumDistances(List<Leg> legs) {
    return legs.isNotEmpty
        ? legs.map((e) => e.distance).reduce((a, b) => a + b)
        : 0;
  }

  /// Sum of durations for a list of legs.
  static Duration sumDurations(List<Leg> legs) {
    return legs.isNotEmpty
        ? legs.map((e) => e.duration).reduce((a, b) => a + b)
        : Duration.zero;
  }

  /// Total biking distance for a list of legs.
  static double getTotalBikingDistance(List<Leg> legs) =>
      sumDistances(legs.where(isBikingLeg).toList());

  /// Total biking duration for a list of legs.
  static Duration getTotalBikingDuration(List<Leg> legs) =>
      sumDurations(legs.where(isBikingLeg).toList());
}
