import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../../domain/entities/itinerary_leg.dart';
import '../../domain/entities/transport_mode.dart';

/// Factory for creating markers for itinerary legs.
class LegMarkerFactory {
  LegMarkerFactory._();

  /// Creates a selected marker for an itinerary leg.
  static TrufiMarker createSelectedMarker({
    required ItineraryLeg leg,
    required Widget transportIcon,
  }) {
    final position = leg.decodedPoints.isNotEmpty
        ? leg.decodedPoints[(leg.decodedPoints.length / 2).floor()]
        : throw StateError('Leg has no decoded points');

    final color = hexToColor(leg.routeColor);
    final displayName = leg.displayName;

    return TrufiMarker(
      id: displayName,
      position: position,
      widget: _buildMarkerWidget(
        color: color,
        transportIcon: transportIcon,
        displayName: displayName,
      ),
      size: const Size(60, 30),
      layerLevel: 2,
    );
  }

  /// Creates an unselected marker for an itinerary leg.
  static TrufiMarker createUnselectedMarker({
    required ItineraryLeg leg,
    required Widget transportIcon,
  }) {
    final position = leg.decodedPoints.isNotEmpty
        ? leg.decodedPoints[(leg.decodedPoints.length / 2).floor()]
        : throw StateError('Leg has no decoded points');

    final displayName = leg.displayName;

    return TrufiMarker(
      id: displayName,
      position: position,
      widget: _buildMarkerWidget(
        color: Colors.grey,
        transportIcon: transportIcon,
        displayName: displayName,
      ),
      size: const Size(60, 30),
      layerLevel: 1,
    );
  }

  static Widget _buildMarkerWidget({
    required Color color,
    required Widget transportIcon,
    required String displayName,
  }) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            SizedBox(
              height: 28,
              width: 28,
              child: transportIcon,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                displayName.isNotEmpty ? displayName : 'no name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a line for an itinerary leg.
  static TrufiLine createLine({
    required ItineraryLeg leg,
    required int layerLevel,
    bool isSelected = false,
  }) {
    final isWalk = leg.transportMode == TransportMode.walk;
    final color = isSelected
        ? (isWalk ? Colors.black : hexToColor(leg.routeColor))
        : Colors.grey.withAlpha(128);

    return TrufiLine(
      id: isSelected ? 'selected-${leg.encodedPoints}' : leg.encodedPoints ?? '',
      position: leg.decodedPoints,
      activeDots: isWalk,
      color: color,
      layerLevel: layerLevel,
      lineWidth: isSelected ? 5 : 4,
    );
  }
}
