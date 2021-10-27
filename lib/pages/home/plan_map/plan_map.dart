import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/configuration/models/itinerary_creator.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/composite_subscription.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
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
    @required this.mapConfiguration,
    this.planPageController,
  }) : super(key: key);

  final PlanPageController planPageController;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;
  final MapConfiguration mapConfiguration;

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
      mapConfiguration: widget.mapConfiguration,
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
    _subscriptions.add(
      widget.planPageController.outSelectePosition.listen((
        position,
      ) {
        _trufiMapController.move(
            center: position, zoom: 14, tickerProvider: this);
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions?.cancel();
    _trufiMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    final trufiConfiguration = context.read<ConfigurationCubit>().state;
    _mapController.onReady.then((value) {
      if (_data.needsCameraUpdate && _data.selectedBounds.isValid) {
        _trufiMapController.fitBounds(
          bounds: _data.selectedBounds,
          tickerProvider: this,
        );
        _data.needsCameraUpdate = false;
      }
    });
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
              if (_data.unselectedMarkersLayer.markers.isNotEmpty)
                _data.unselectedMarkersLayer,
              _data.selectedPolylinesLayer,
              if (_data.selectedMarkersLayer.markers.isNotEmpty)
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
      _cropButtonKey?.currentState?.setVisible(
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
    @required this.mapConfiguration,
  }) {
    if (plan != null) {
      if (plan.from != null) {
        _fromMarker = mapConfiguration.markersConfiguration
            .buildFromMarker(createLatLngWithPlanLocation(plan.from));
      }
      if (plan.to != null) {
        _toMarker = mapConfiguration.markersConfiguration
            .buildToMarker(createLatLngWithPlanLocation(plan.to));
      }
    }
  }

  final PlanEntity plan;
  final ValueChanged<PlanItinerary> onItineraryTap;
  final MapConfiguration mapConfiguration;

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
    return MarkerLayerOptions(markers: [..._selectedMarkers, _fromMarker]);
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
    _itineraries.addAll(mapConfiguration.itinararyCreator.buildItineraries(
      plan: plan,
      selectedItinerary: _selectedItinerary,
      onTap: onItineraryTap,
    ));
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
}
