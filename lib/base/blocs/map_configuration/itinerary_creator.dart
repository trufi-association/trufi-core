// import 'package:flutter/material.dart';

// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:trufi_core/base/models/enums/transport_mode.dart';
// import 'package:trufi_core/base/models/journey_plan/plan.dart';
// import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';
// import 'package:trufi_core/base/widgets/maps/utils/trufi_map_utils.dart';

// enum TransportMarkers {
//   show,
//   hideMarker,
// }

// abstract class ItinararyCreator {
//   Map<Itinerary, List<PolylineWithMarkers>> buildItineraries({
//     required Plan plan,
//     required Itinerary selectedItinerary,
//     required Function(Itinerary) onTap,
//   });
// }

// class DefaultItineraryCreator implements ItinararyCreator {
//   final TransportMarkers transportMarkers;

//   const DefaultItineraryCreator({
//     this.transportMarkers = TransportMarkers.show,
//   });

//   @override
//   Map<Itinerary, List<PolylineWithMarkers>> buildItineraries({
//     required Plan plan,
//     required Itinerary selectedItinerary,
//     required Function(Itinerary p1) onTap,
//   }) {
//     final itineraries = <Itinerary, List<PolylineWithMarkers>>{};
//     if (plan.itineraries != null) {
//       for (final itinerary in plan.itineraries!) {
//         final List<Marker> markers = [];
//         final List<PolylineWithMarkers> polylinesWithMarkers = [];
//         final bool isSelected = itinerary == selectedItinerary;

//         final List<Leg> compressedLegs = itinerary.compressLegs;
//         for (int i = 0; i < compressedLegs.length; i++) {
//           final Leg leg = compressedLegs[i];
//           // Polyline
//           final List<LatLng> points = leg.accumulatedPoints.isNotEmpty
//               ? leg.accumulatedPoints
//               : decodePolyline(leg.points);

//           final color = isSelected
//               ? leg.transitLeg
//                   ? leg.route?.primaryColor ?? leg.transportMode.backgroundColor
//                   : leg.transportMode.color
//               : Colors.grey;

//           final Polyline polyline = Polyline(
//             points: points,
//             color: color,
//             strokeWidth: isSelected ? 6.0 : 3.0,
//             isDotted: leg.transportMode == TransportMode.walk,
//           );

//           // Transfer marker
//           if (isSelected &&
//               i < compressedLegs.length - 1 &&
//               points.isNotEmpty) {
//             markers.add(
//               buildTransferMarker(
//                 points[points.length - 1],
//               ),
//             );
//           }

//           // Bus marker
//           if (transportMarkers != TransportMarkers.hideMarker &&
//               leg.transitLeg) {
//             markers.add(
//               buildTransportMarker(
//                 midPointForPoints(points),
//                 color,
//                 leg,
//                 onTap: () => onTap(itinerary),
//               ),
//             );
//           }
//           polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
//         }

//         itineraries.addAll({itinerary: polylinesWithMarkers});
//       }
//     }
//     return itineraries;
//   }
// }
