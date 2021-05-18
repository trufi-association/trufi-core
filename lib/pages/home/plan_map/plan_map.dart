import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/composite_subscription.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/markers/marker_configuration.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/widgets/map/buttons/crop_button.dart';
import 'package:trufi_core/widgets/map/buttons/map_type_button.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';

import '../../../widgets/map/utils/trufi_map_utils.dart';

const double customOverlayWidgetMargin = 80.0;

typedef OnSelected = void Function(PlanItinerary itinerary);

class PlanMapPage extends StatefulWidget {
  const PlanMapPage({
    Key key,
    @required this.customOverlayWidget,
    @required this.customBetweenFabWidget,
    @required this.markerConfiguration,
    this.planPageController,
  }) : super(key: key);

  final PlanPageController planPageController;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;
  final MarkerConfiguration markerConfiguration;

  @override
  PlanMapPageState createState() => PlanMapPageState();
}

class PlanMapPageState extends State<PlanMapPage>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  final _subscriptions = CompositeSubscription();
  final _trufiMapController = TrufiMapController();

  PlanMapPageStateData _data;

  @override
  void initState() {
    super.initState();
    _data = PlanMapPageStateData(
      plan: widget.planPageController.plan,
      onItineraryTap: widget.planPageController.inSelectedItinerary.add,
      markerConfiguration: widget.markerConfiguration,
    );
    _subscriptions.add(
      _trufiMapController.outMapReady.listen((_) {
        setState(() {
          _data.needsCameraUpdate = true;
        });
      }),
    );
    _subscriptions.add(
      widget.planPageController.outSelectedItinerary.listen((
        selectedItinerary,
      ) {
        setState(() {
          _data.selectedItinerary = selectedItinerary;
          _data.needsCameraUpdate = true;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    _trufiMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    final trufiConfiguration = context.read<ConfigurationCubit>().state;

    if (_mapController.ready) {
      if (_data.needsCameraUpdate && _data.selectedBounds.isValid) {
        _trufiMapController.fitBounds(
          bounds: _data.selectedBounds,
          tickerProvider: this,
        );
        _data.needsCameraUpdate = false;
      }
    }
    return Stack(
      children: <Widget>[
        TrufiMap(
          key: const ValueKey("PlanMap"),
          controller: _trufiMapController,
          onTap: _handleOnMapTap,
          onPositionChanged: _handleOnMapPositionChanged,
          layerOptionsBuilder: (context) {
            return <LayerOptions>[
              _data.unselectedPolylinesLayer,
              _data.unselectedMarkersLayer,
              _data.selectedPolylinesLayer,
              _data.selectedMarkersLayer,
              _data.fromMarkerLayer,
              // _trufiMapController.yourLocationLayer,
              _data.toMarkerLayer,
            ];
          },
        ),
        const Positioned(
          top: 16.0,
          right: 16.0,
          child: MapTypeButton(),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: trufiConfiguration.map.mapAttributionBuilder(context),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CropButton(key: _cropButtonKey, onPressed: _handleOnCropPressed),
              const Padding(padding: EdgeInsets.all(4.0)),
              YourLocationButton(
                trufiMapController: _trufiMapController,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(
              right: customOverlayWidgetMargin,
              bottom: 60,
            ),
            child: widget.customOverlayWidget != null
                ? widget.customOverlayWidget(context, locale)
                : null,
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.only(
              left:
                  MediaQuery.of(context).size.width - customOverlayWidgetMargin,
              bottom: 80,
              top: 65,
            ),
            child: widget.customBetweenFabWidget != null
                ? widget.customBetweenFabWidget(context)
                : null,
          ),
        )
      ],
    );
  }

  void _handleOnMapTap(LatLng point) {
    final PlanItinerary tappedItinerary = _data.itineraryForPoint(point);
    if (tappedItinerary != null) {
      widget.planPageController.inSelectedItinerary.add(tappedItinerary);
    }
  }

  void _handleOnMapPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (_data.selectedBounds != null && _data.selectedBounds.isValid) {
      _cropButtonKey.currentState.setVisible(
        visible: !position.bounds.containsBounds(_data.selectedBounds),
      );
    }
  }

  void _handleOnCropPressed() {
    setState(() {
      _data.needsCameraUpdate = true;
    });
  }

  // Getter

  MapController get _mapController {
    return _trufiMapController.mapController;
  }
}

class PlanMapPageStateData {
  PlanMapPageStateData({
    @required this.plan,
    @required this.onItineraryTap,
    @required this.markerConfiguration,
  }) {
    if (plan != null) {
      if (plan.from != null) {
        _fromMarker = markerConfiguration
            .buildFromMarker(createLatLngWithPlanLocation(plan.from));
      }
      if (plan.to != null) {
        _toMarker = markerConfiguration
            .buildToMarker(createLatLngWithPlanLocation(plan.to));
      }
    }
  }

  final PlanEntity plan;
  final ValueChanged<PlanItinerary> onItineraryTap;
  final MarkerConfiguration markerConfiguration;

  final _itineraries = <PlanItinerary, List<PolylineWithMarkers>>{};
  final _unselectedMarkers = <Marker>[];
  final _unselectedPolylines = <Polyline>[];
  final _selectedMarkers = <Marker>[];
  final _selectedPolylines = <Polyline>[];
  final _allPolylines = <Polyline>[];

  Marker _fromMarker;
  Marker _toMarker;

  LatLngBounds _selectedBounds = LatLngBounds();
  PlanItinerary _selectedItinerary;

  bool needsCameraUpdate = true;

  void clear() {
    _itineraries.clear();
    _unselectedMarkers.clear();
    _unselectedPolylines.clear();
    _selectedMarkers.clear();
    _selectedPolylines.clear();
    _allPolylines.clear();
    _selectedBounds = LatLngBounds();
  }

  // Getter

  MarkerLayerOptions get fromMarkerLayer {
    return MarkerLayerOptions(
      markers: _fromMarker != null ? [_fromMarker] : [],
    );
  }

  MarkerLayerOptions get toMarkerLayer {
    return MarkerLayerOptions(
      markers: _toMarker != null ? [_toMarker] : [],
    );
  }

  MarkerLayerOptions get unselectedMarkersLayer {
    return MarkerLayerOptions(markers: _unselectedMarkers);
  }

  PolylineLayerOptions get unselectedPolylinesLayer {
    return PolylineLayerOptions(polylines: _unselectedPolylines);
  }

  MarkerLayerOptions get selectedMarkersLayer {
    return MarkerLayerOptions(markers: _selectedMarkers);
  }

  PolylineLayerOptions get selectedPolylinesLayer {
    return PolylineLayerOptions(polylines: _selectedPolylines);
  }

  LatLngBounds get selectedBounds => _selectedBounds;

  PlanItinerary get selectedItinerary => _selectedItinerary;

  // Setter

  set selectedItinerary(PlanItinerary selectedItinerary) {
    clear();
    _selectedItinerary = selectedItinerary;
    if (_fromMarker != null) {
      _selectedBounds.extend(_fromMarker.point);
    }
    if (_toMarker != null) {
      _selectedBounds.extend(_toMarker.point);
    }
    _itineraries.addAll(
      _createItineraries(
        plan: plan,
        selectedItinerary: _selectedItinerary,
        onTap: onItineraryTap,
      ),
    );
    _itineraries.forEach((itinerary, polylinesWithMarker) {
      final bool isSelected = itinerary == _selectedItinerary;
      for (final polylineWithMarker in polylinesWithMarker) {
        for (final marker in polylineWithMarker.markers) {
          if (isSelected) {
            _selectedMarkers.add(marker);
            _selectedBounds.extend(marker.point);
          } else {
            _unselectedMarkers.add(marker);
          }
        }
        if (isSelected) {
          _selectedPolylines.add(polylineWithMarker.polyline);
          for (final point in polylineWithMarker.polyline.points) {
            _selectedBounds.extend(point);
          }
        } else {
          _unselectedPolylines.add(polylineWithMarker.polyline);
        }
        _allPolylines.add(polylineWithMarker.polyline);
      }
    });
  }

  // Helper

  PlanItinerary itineraryForPoint(LatLng point) {
    return _itineraryForPolyline(polylineHitTest(_unselectedPolylines, point));
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    final entry = _itineraryEntryForPolyline(polyline);
    return entry?.key;
  }

  MapEntry<PlanItinerary, List<PolylineWithMarkers>> _itineraryEntryForPolyline(
    Polyline polyline,
  ) {
    return _itineraries.entries.firstWhere(
      (pair) {
        return null !=
            pair.value.firstWhere(
              (pwm) => pwm.polyline == polyline,
              orElse: () => null,
            );
      },
      orElse: () => null,
    );
  }

  Map<PlanItinerary, List<PolylineWithMarkers>> _createItineraries({
    @required PlanEntity plan,
    @required PlanItinerary selectedItinerary,
    @required Function(PlanItinerary) onTap,
  }) {
    final Map<PlanItinerary, List<PolylineWithMarkers>> itineraries = {};
    if (plan != null) {
      for (final itinerary in plan.itineraries) {
        final List<Marker> markers = [];
        final List<PolylineWithMarkers> polylinesWithMarkers = [];
        final bool isSelected = itinerary == selectedItinerary;

        for (int i = 0; i < itinerary.legs.length; i++) {
          final PlanItineraryLeg leg = itinerary.legs[i];
          // Polyline
          final List<LatLng> points = decodePolyline(leg.points);
          final Color color =
              isSelected ? leg.transportMode.color : Colors.grey;
          final Polyline polyline = Polyline(
            points: points,
            color: color,
            strokeWidth: isSelected ? 6.0 : 3.0,
            isDotted: leg.transportMode == TransportMode.walk,
          );

          // Transfer marker
          if (isSelected &&
              i < itinerary.legs.length - 1 &&
              polyline.points.isNotEmpty) {
            markers.add(
              buildTransferMarker(
                polyline.points[polyline.points.length - 1],
              ),
            );
          }

          // Bus marker
          if (leg.transportMode != TransportMode.walk) {
            markers.add(
              buildBusMarker(
                midPointForPolyline(polyline),
                color,
                leg,
                onTap: () => onTap(itinerary),
              ),
            );
          }
          polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
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
