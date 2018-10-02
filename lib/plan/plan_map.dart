import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/crop_button.dart';
import 'package:trufi_app/widgets/trufi_map.dart';
import 'package:trufi_app/widgets/your_location_button.dart';

typedef void OnSelected(PlanItinerary itinerary);

class PlanMapPage extends StatefulWidget {
  PlanMapPage({
    this.plan,
    this.initialPosition,
    this.onSelected,
    this.selectedItinerary,
  });

  final Plan plan;
  final LatLng initialPosition;
  final OnSelected onSelected;
  final PlanItinerary selectedItinerary;

  @override
  PlanMapPageState createState() => PlanMapPageState();
}

class PlanMapPageState extends State<PlanMapPage> {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  final _subscriptions = CompositeSubscription();
  final _trufiOnAndOfflineMapController = TrufiOnAndOfflineMapController();
  final _itineraries = Map<PlanItinerary, List<PolylineWithMarkers>>();
  final _polylines = List<Polyline>();
  final _backgroundMarkers = List<Marker>();
  final _foregroundMarkers = List<Marker>();
  final _selectedMarkers = List<Marker>();
  final _selectedPolylines = List<Polyline>();

  Plan _plan;
  PlanItinerary _selectedItinerary;
  LatLngBounds _selectedBounds = LatLngBounds();
  bool _needsCameraUpdate = true;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      _trufiOnAndOfflineMapController.outMapReady.listen((_) {
        setState(() {
          _needsCameraUpdate = true;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    _trufiOnAndOfflineMapController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // Clear content
    _needsCameraUpdate = _needsCameraUpdate ||
        widget.plan != _plan ||
        widget.selectedItinerary != _selectedItinerary;
    _plan = widget.plan;
    _selectedItinerary = widget.selectedItinerary;
    _itineraries.clear();
    _backgroundMarkers.clear();
    _foregroundMarkers.clear();
    _polylines.clear();
    _selectedMarkers.clear();
    _selectedPolylines.clear();
    _selectedBounds = LatLngBounds();

    // Build markers and polylines
    if (_plan != null) {
      if (_plan.from != null) {
        LatLng point = createLatLngWithPlanLocation(_plan.from);
        _backgroundMarkers.add(buildFromMarker(point));
        _selectedBounds.extend(point);
      }
      if (_plan.to != null) {
        LatLng point = createLatLngWithPlanLocation(_plan.to);
        _foregroundMarkers.add(buildToMarker(point));
        _selectedBounds.extend(point);
      }
      if (_plan.itineraries.isNotEmpty) {
        if (_selectedItinerary == null ||
            !_plan.itineraries.contains(_selectedItinerary)) {
          _selectedItinerary = _plan.itineraries.first;
        }
        _itineraries.addAll(
          createItineraries(_plan, _selectedItinerary, _setItinerary),
        );
        _itineraries.forEach((itinerary, polylinesWithMarker) {
          bool isSelected = itinerary == _selectedItinerary;
          polylinesWithMarker.forEach((polylineWithMarker) {
            polylineWithMarker.markers.forEach((marker) {
              if (isSelected) {
                _selectedMarkers.add(marker);
                _selectedBounds.extend(marker.point);
              } else {
                _backgroundMarkers.add(marker);
              }
            });
            if (isSelected) {
              _selectedPolylines.add(polylineWithMarker.polyline);
              polylineWithMarker.polyline.points.forEach((point) {
                _selectedBounds.extend(point);
              });
            } else {
              _polylines.add(polylineWithMarker.polyline);
            }
          });
        });
      }
    }
    if (_needsCameraUpdate && _selectedBounds.isValid && _mapController.ready) {
      _mapController.fitBounds(_selectedBounds);
      _needsCameraUpdate = false;
    }
    return Stack(
      children: <Widget>[
        TrufiOnAndOfflineMap(
          key: ValueKey("PlanMap"),
          controller: _trufiOnAndOfflineMapController,
          onTap: _handleOnMapTap,
          onPositionChanged: _handleOnMapPositionChanged,
          layerOptionsBuilder: (context) {
            return <LayerOptions>[
              PolylineLayerOptions(polylines: _polylines),
              MarkerLayerOptions(markers: _backgroundMarkers),
              PolylineLayerOptions(polylines: _selectedPolylines),
              MarkerLayerOptions(markers: _selectedMarkers),
              _trufiOnAndOfflineMapController.yourLocationLayer,
              MarkerLayerOptions(markers: _foregroundMarkers),
            ];
          },
        ),
        Positioned(
          bottom: 36.0,
          right: 16.0,
          child: _buildFloatingActionButtons(context),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CropButton(key: _cropButtonKey, onPressed: _handleOnCropPressed),
        YourLocationButton(onPressed: _handleOnYourLocationPressed),
      ],
    );
  }

  void _handleOnMapTap(LatLng point) {
    Polyline polyline = polylineHitTest(_polylines, point);
    if (polyline != null) {
      _setItinerary(_itineraryForPolyline(polyline));
    }
  }

  void _handleOnMapPositionChanged(MapPosition position) {
    if (_selectedBounds != null && _selectedBounds.isValid) {
      _cropButtonKey.currentState.setVisible(
        !position.bounds.containsBounds(_selectedBounds),
      );
    }
  }

  void _handleOnYourLocationPressed() async {
    _trufiOnAndOfflineMapController.moveToYourLocation(context);
  }

  void _handleOnCropPressed() {
    setState(() {
      _needsCameraUpdate = true;
    });
  }

  void _setItinerary(PlanItinerary value) {
    setState(() {
      _selectedItinerary = value;
      _needsCameraUpdate = true;
      if (widget.onSelected != null) {
        widget.onSelected(_selectedItinerary);
      }
    });
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    final entry = _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
  }

  MapEntry<PlanItinerary, List<PolylineWithMarkers>> _itineraryEntryForPolyline(
    Polyline polyline,
  ) {
    return _itineraries.entries.firstWhere((pair) {
      return null !=
          pair.value.firstWhere(
            (pwm) => pwm.polyline == polyline,
            orElse: () => null,
          );
    }, orElse: () => null);
  }

  // Getter

  MapController get _mapController {
    return _trufiOnAndOfflineMapController.mapController;
  }
}
