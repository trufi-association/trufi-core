import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/navigation_localizations.dart';

/// Type of navigation instruction.
enum InstructionType {
  // Transit instructions
  /// Board a transport vehicle at a stop.
  boardTransport,

  /// Riding on transport, showing remaining stops.
  rideTransport,

  /// Exit the transport at a stop.
  exitTransport,

  // Walking instructions
  /// Walk straight/continue.
  walkStraight,

  /// Turn left.
  turnLeft,

  /// Turn right.
  turnRight,

  /// Turn slightly left.
  turnSlightLeft,

  /// Turn slightly right.
  turnSlightRight,

  /// Make a U-turn.
  uTurn,

  /// Arrived at final destination.
  arriveDestination,

  /// Arrived at a transit stop (to board).
  arriveStop,

  /// Depart from current location.
  depart,
}

/// Localizable text key for instruction texts that are produced in layers
/// without a [BuildContext] (e.g. the navigation cubit).
///
/// Resolved to a localized string at the widget layer via
/// [NavigationInstruction.resolvedPrimaryText].
enum InstructionTextKey {
  /// "You have arrived" — shown when the destination is reached.
  youHaveArrived,

  /// "Final destination" — preview label for the last stop.
  finalDestination,
}

/// A navigation instruction to display to the user.
class NavigationInstruction {
  /// The type of instruction.
  final InstructionType type;

  /// Primary text to display (e.g., "Turn left onto Main Street").
  ///
  /// Widgets should render [resolvedPrimaryText] instead of reading this
  /// field directly, so that [primaryTextKey] based texts get localized.
  final String primaryText;

  /// Localizable key for the primary text.
  ///
  /// When set, it takes precedence over [primaryText] in
  /// [resolvedPrimaryText]. Used by layers without a [BuildContext].
  final InstructionTextKey? primaryTextKey;

  /// Secondary text (e.g., "in 50m").
  final String? secondaryText;

  /// Stop name for transit stops.
  final String? stopName;

  /// Distance in meters.
  final double? distance;

  /// Duration to this point.
  final Duration? duration;

  /// Position of this instruction.
  final LatLng? position;

  /// Relative direction from OTP Step (e.g., "LEFT", "RIGHT").
  final String? relativeDirection;

  /// Route color for transit badge display.
  final Color? routeColor;

  /// Route short name (e.g., "101", "A").
  final String? routeShortName;

  /// Mode icon for the transport.
  final Widget? modeIcon;

  const NavigationInstruction({
    required this.type,
    this.primaryText = '',
    this.primaryTextKey,
    this.secondaryText,
    this.stopName,
    this.distance,
    this.duration,
    this.position,
    this.relativeDirection,
    this.routeColor,
    this.routeShortName,
    this.modeIcon,
  });

  /// The primary text to render, resolving [primaryTextKey] to a localized
  /// string when set and falling back to [primaryText] otherwise.
  String resolvedPrimaryText(NavigationLocalizations localizations) {
    return switch (primaryTextKey) {
      InstructionTextKey.youHaveArrived => localizations.navArrivedShort,
      InstructionTextKey.finalDestination => localizations.navFinalDestination,
      null => primaryText,
    };
  }

  /// Get the appropriate icon for this instruction type.
  IconData get icon {
    return switch (type) {
      InstructionType.boardTransport => Icons.directions_bus_rounded,
      InstructionType.rideTransport => Icons.directions_transit_rounded,
      InstructionType.exitTransport => Icons.exit_to_app_rounded,
      InstructionType.walkStraight => Icons.straight_rounded,
      InstructionType.turnLeft => Icons.turn_left_rounded,
      InstructionType.turnRight => Icons.turn_right_rounded,
      InstructionType.turnSlightLeft => Icons.turn_slight_left_rounded,
      InstructionType.turnSlightRight => Icons.turn_slight_right_rounded,
      InstructionType.uTurn => Icons.u_turn_left_rounded,
      InstructionType.arriveDestination => Icons.flag_rounded,
      InstructionType.arriveStop => Icons.location_on_rounded,
      InstructionType.depart => Icons.my_location_rounded,
    };
  }

  /// Whether this is a transit-related instruction.
  bool get isTransit =>
      type == InstructionType.boardTransport ||
      type == InstructionType.rideTransport ||
      type == InstructionType.exitTransport;

  /// Whether this is a walking-related instruction.
  bool get isWalking =>
      type == InstructionType.walkStraight ||
      type == InstructionType.turnLeft ||
      type == InstructionType.turnRight ||
      type == InstructionType.turnSlightLeft ||
      type == InstructionType.turnSlightRight ||
      type == InstructionType.uTurn ||
      type == InstructionType.depart;

  NavigationInstruction copyWith({
    InstructionType? type,
    String? primaryText,
    InstructionTextKey? primaryTextKey,
    String? secondaryText,
    String? stopName,
    double? distance,
    Duration? duration,
    LatLng? position,
    String? relativeDirection,
    Color? routeColor,
    String? routeShortName,
    Widget? modeIcon,
  }) {
    return NavigationInstruction(
      type: type ?? this.type,
      primaryText: primaryText ?? this.primaryText,
      primaryTextKey: primaryTextKey ?? this.primaryTextKey,
      secondaryText: secondaryText ?? this.secondaryText,
      stopName: stopName ?? this.stopName,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      relativeDirection: relativeDirection ?? this.relativeDirection,
      routeColor: routeColor ?? this.routeColor,
      routeShortName: routeShortName ?? this.routeShortName,
      modeIcon: modeIcon ?? this.modeIcon,
    );
  }
}
