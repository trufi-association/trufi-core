import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/transit_route_models.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:uuid/uuid.dart';

class LeafletMapRouteEditor extends StatefulWidget implements IMapRouteEditor {
  @override
  final LeafletMapController trufiMapController;
  @override
  final Function(List<TrufiLatLng>) onAreaSelected;
  @override
  final bool isSelectionArea;

  const LeafletMapRouteEditor({
    super.key,
    required this.trufiMapController,
    required this.onAreaSelected,
    this.isSelectionArea = true,
  });

  @override
  State<LeafletMapRouteEditor> createState() => _LeafletMapRouteEditorState();
}

class _LeafletMapRouteEditorState extends State<LeafletMapRouteEditor> {
  late RangeValues values;

  List<RouteSegment> square = [];
  TransitRoute? transitRoute;

  @override
  void initState() {
    final routeTransportsCubit = context.read<RouteTransportsCubit>();
    transitRoute = routeTransportsCubit.state.transports.firstWhereOrNull(
      (element) => element.code == "1:4269608::01",
    );
    values = RangeValues(1, (transitRoute!.geometry!.length) + 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapConfiguration = context.read<MapConfigurationCubit>().state;
    return Stack(
      children: [
        LeafletMap(
          trufiMapController: widget.trufiMapController,
          layerOptionsBuilder: (context) => [
            PolylineLayer(
              polylines: [
                Polyline(
                  points:
                      TrufiLatLng.toListLatLng(transitRoute?.geometry ?? []),
                  color: transitRoute?.route?.backgroundColor ?? Colors.black,
                  strokeWidth: 6.0,
                ),
              ],
            ),
            PolylineLayer(
              polylines: square
                  .map(
                    (e) => Polyline(
                      points: TrufiLatLng.toListLatLng(e.points),
                      color: Colors.black,
                      strokeWidth: 9.0,
                    ),
                  )
                  .toList(),
            ),
            if (transitRoute?.geometry != null)
              MarkerLayer(markers: [
                if (transitRoute!.geometry!.length > 2)
                  buildFromMarker(transitRoute!.geometry![0],
                      mapConfiguration.markersConfiguration.fromMarker),
                if (transitRoute!.geometry!.length > 2)
                  buildToMarker(
                      transitRoute!
                          .geometry![transitRoute!.geometry!.length - 1],
                      mapConfiguration.markersConfiguration.toMarker),
              ]),
          ],
          onPositionChanged: (mapPosition, hasGesture) {},
        ),
        TextButton(
          onPressed: () {},
          child: Text("Save"),
        ),
        Positioned(
          bottom: 100,
          top: 20,
          right: 20,
          child: Center(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              width: 50,
              child: RotatedBox(
                quarterTurns: -1,
                child: Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 0.0), // Set overlayRadius to 0
                        ),
                        child: RangeSlider(
                          divisions: transitRoute!.geometry!.length - 1,
                          min: 1,
                          max: transitRoute!.geometry!.length + 0.0,
                          values: values,
                          onChanged: (newValues) {
                            final data = <TrufiLatLng>[];
                            transitRoute?.geometry?.forEach((element) {});
                            for (var i = 0;
                                i < transitRoute!.geometry!.length;
                                i++) {
                              if (i >= newValues.start && i <= newValues.end) {
                                data.add(transitRoute!.geometry![i]);
                              }
                            }
                            setState(() {
                              values = newValues;
                              square = [
                                RouteSegment(
                                  id: const Uuid().v4(),
                                  start: data.first,
                                  end: data.last,
                                  points: data,
                                )
                              ];
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class MultiRangeSlider extends StatelessWidget {
//   // divisions: transitRoute!.geometry!.length - 1,
//   // min: 1,
//   // max: transitRoute!.geometry!.length + 0.0,
//   // values: values,
//   // onChanged: (newValues) {
//     RangeValues values(){}
//   const MultiRangeSlider({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         color: Colors.white,
//         padding: EdgeInsets.symmetric(vertical: 20),
//         width: 50,
//         child: RotatedBox(
//           quarterTurns: -1,
//           child: Row(
//             children: [
//               Expanded(
//                 child: SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     overlayShape: const RoundSliderOverlayShape(
//                         overlayRadius: 0.0), // Set overlayRadius to 0
//                   ),
//                   child: RangeSlider(
//                     divisions: transitRoute!.geometry!.length - 1,
//                     min: 1,
//                     max: transitRoute!.geometry!.length + 0.0,
//                     values: values,
//                     onChanged: (newValues) {
//                       final data = <TrufiLatLng>[];
//                       transitRoute?.geometry?.forEach((element) {});
//                       for (var i = 0; i < transitRoute!.geometry!.length; i++) {
//                         if (i >= newValues.start && i <= newValues.end) {
//                           data.add(transitRoute!.geometry![i]);
//                         }
//                       }
//                       setState(() {
//                         values = newValues;
//                         square = [
//                           RouteSegment(
//                             id: const Uuid().v4(),
//                             start: data.first,
//                             end: data.last,
//                             points: data,
//                           )
//                         ];
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     overlayShape: const RoundSliderOverlayShape(
//                         overlayRadius: 0.0), // Set overlayRadius to 0
//                   ),
//                   child: RangeSlider(
//                     divisions: transitRoute!.geometry!.length - 1,
//                     min: 1,
//                     max: transitRoute!.geometry!.length + 0.0,
//                     values: values,
//                     onChanged: (newValues) {
//                       final data = <TrufiLatLng>[];
//                       transitRoute?.geometry?.forEach((element) {});
//                       for (var i = 0; i < transitRoute!.geometry!.length; i++) {
//                         if (i >= newValues.start && i <= newValues.end) {
//                           data.add(transitRoute!.geometry![i]);
//                         }
//                       }
//                       setState(() {
//                         values = newValues;
//                         square = [
//                           RouteSegment(
//                             id: const Uuid().v4(),
//                             start: data.first,
//                             end: data.last,
//                             points: data,
//                           )
//                         ];
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
