import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/widgets/map/utils/trufi_map_utils.dart';

enum TransportMarkers {
  show,
  hideIcon,
  hideText,
  hideMarker,
}

abstract class ItinararyCreator {
  Map<PlanItinerary, List<PolylineWithMarkers>> buildItineraries({
    required PlanEntity? plan,
    required PlanItinerary? selectedItinerary,
    required Function(PlanItinerary) onTap,
  });
}

class DefaultItineraryCreator implements ItinararyCreator {
  final TransportMarkers transportMarkers;

  const DefaultItineraryCreator({
    this.transportMarkers = TransportMarkers.show,
  });

  @override
  Map<PlanItinerary, List<PolylineWithMarkers>> buildItineraries({
    required PlanEntity? plan,
    required PlanItinerary? selectedItinerary,
    required Function(PlanItinerary p1) onTap,
  }) {
    final Map<PlanItinerary, List<PolylineWithMarkers>> itineraries = {};
    if (plan != null) {
      for (final itinerary in plan.itineraries!) {
        final List<Marker> markers = [];
        final List<PolylineWithMarkers> polylinesWithMarkers = [];
        final bool isSelected = itinerary == selectedItinerary;
        final bool showOnlySelected = selectedItinerary!.isOnlyShowItinerary;

        if (!showOnlySelected || isSelected) {
          final List<PlanItineraryLeg?> compressedLegs = itinerary.compressLegs;
          for (int i = 0; i < compressedLegs.length; i++) {
            final PlanItineraryLeg leg = compressedLegs[i]!;
            // Polyline
            final List<LatLng> points = leg.accumulatedPoints.isNotEmpty
                ? leg.accumulatedPoints
                : decodePolyline(leg.points!);
            final Color color = isSelected
                ? leg.transportMode == TransportMode.bicycle &&
                        leg.fromPlace!.bikeRentalStation != null
                    ? getBikeRentalNetwork(
                            leg.fromPlace!.bikeRentalStation!.networks![0])
                        .color
                    : (leg.route?.color != null
                        ? Color(int.tryParse("0xFF${leg.route!.color}")!)
                        : leg.transportMode == TransportMode.walk
                            ? leg.transportMode.color
                            : leg.transportMode.backgroundColor)
                : Colors.grey;

            final Polyline polyline = Polyline(
              points: points,
              color: color,
              strokeWidth: isSelected ? 6.0 : 3.0,
              isDotted: leg.transportMode == TransportMode.walk,
            );

            // Transfer marker
            if (isSelected &&
                i < compressedLegs.length - 1 &&
                polyline.points.isNotEmpty) {
              markers.add(
                buildTransferMarker(
                  polyline.points[polyline.points.length - 1],
                ),
              );
            }

            // Bus marker
            if (transportMarkers != TransportMarkers.hideMarker &&
                leg.transportMode != TransportMode.walk &&
                leg.transportMode != TransportMode.bicycle &&
                leg.transportMode != TransportMode.car) {
              markers.add(
                buildBusMarker(
                  midPointForPolyline(polyline)!,
                  isSelected
                      ? (leg.route?.color != null
                          ? Color(int.tryParse("0xFF${leg.route!.color}")!)
                          : leg.transportMode.backgroundColor)
                      : Colors.grey,
                  leg,
                  icon: (leg.route?.type ?? 0) == 715
                      ? onDemandTaxiSvg(color: 'FFFFFF')
                      : null,
                  onTap: () => onTap(itinerary),
                ),
              );
            }
            polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
          }
        }
        itineraries.addAll({itinerary: polylinesWithMarkers});
      }
    }
    return itineraries;
  }
}

class PolylineWithMarkers {
  PolylineWithMarkers(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}
