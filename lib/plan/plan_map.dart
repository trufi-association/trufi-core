import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/plan/plan.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/crop_button.dart';
import 'package:trufi_app/widgets/trufi_map.dart';
import 'package:trufi_app/widgets/trufi_online_map.dart';
import 'package:trufi_app/widgets/your_location_button.dart';

typedef void OnSelected(PlanItinerary itinerary);

class PlanMapPage extends StatefulWidget {
  PlanMapPage({this.planPageController});

  final PlanPageController planPageController;

  @override
  PlanMapPageState createState() => PlanMapPageState();
}

class PlanMapPageState extends State<PlanMapPage> {
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

  Widget build(BuildContext context) {
    if (_mapController.ready) {
      if (_data.needsCameraUpdate && _data.selectedBounds.isValid) {
        _mapController.fitBounds(_data.selectedBounds);
        _data.needsCameraUpdate = false;
      }
    }
    return Stack(
      children: <Widget>[
        TrufiOnlineMap(
          key: ValueKey("PlanMap"),
          controller: _trufiMapController,
          onTap: _handleOnMapTap,
          onPositionChanged: _handleOnMapPositionChanged,
          layerOptionsBuilder: (context) {
            return <LayerOptions>[
              _data.unselectedPolylinesLayer,
              _data.unselectedMarkersLayer,
              _data.fromMarkerLayer,
              _data.selectedPolylinesLayer,
              _data.selectedMarkersLayer,
              _trufiMapController.yourLocationLayer,
              _data.toMarkerLayer,
            ];
          },
        ),
        Positioned(
          bottom: 24.0,
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
        Padding(padding: EdgeInsets.all(4.0)),
        YourLocationButton(onPressed: _handleOnYourLocationPressed),
      ],
    );
  }

  void _handleOnMapTap(LatLng point) {
    PlanItinerary tappedItinerary = _data.itineraryForPoint(point);
    if (tappedItinerary != null) {
      widget.planPageController.inSelectedItinerary.add(tappedItinerary);
    }
  }

  void _handleOnMapPositionChanged(MapPosition position) {
    if (_data.selectedBounds != null && _data.selectedBounds.isValid) {
      _cropButtonKey.currentState.setVisible(
        !position.bounds.containsBounds(_data.selectedBounds),
      );
    }
  }

  void _handleOnYourLocationPressed() async {
    _trufiMapController.moveToYourLocation(context);
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
  }) {
    if (plan != null) {
      if (plan.from != null) {
        _fromMarker = buildFromMarker(createLatLngWithPlanLocation(plan.from));
      }
      if (plan.to != null) {
        _toMarker = buildToMarker(createLatLngWithPlanLocation(plan.to));
      }
    }
  }

  final Plan plan;
  final ValueChanged<PlanItinerary> onItineraryTap;

  final _itineraries = Map<PlanItinerary, List<PolylineWithMarkers>>();
  final _unselectedMarkers = List<Marker>();
  final _unselectedPolylines = List<Polyline>();
  final _selectedMarkers = List<Marker>();
  final _selectedPolylines = List<Polyline>();
  final _allPolylines = List<Polyline>();

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
      bool isSelected = (itinerary == _selectedItinerary);
      polylinesWithMarker.forEach((polylineWithMarker) {
        polylineWithMarker.markers.forEach((marker) {
          if (isSelected) {
            _selectedMarkers.add(marker);
            _selectedBounds.extend(marker.point);
          } else {
            _unselectedMarkers.add(marker);
          }
        });
        if (isSelected) {
          _selectedPolylines.add(polylineWithMarker.polyline);
          polylineWithMarker.polyline.points.forEach((point) {
            _selectedBounds.extend(point);
          });
        } else {
          _unselectedPolylines.add(polylineWithMarker.polyline);
        }
        _allPolylines.add(polylineWithMarker.polyline);
      });
    });
  }

  // Helper

  PlanItinerary itineraryForPoint(LatLng point) {
    return _itineraryForPolyline(polylineHitTest(_allPolylines, point));
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    final entry = _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
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
    @required Plan plan,
    @required PlanItinerary selectedItinerary,
    @required Function(PlanItinerary) onTap,
  }) {
    Map<PlanItinerary, List<PolylineWithMarkers>> itineraries = Map();
    if (plan != null) {
      plan.itineraries.forEach((itinerary) {
        List<Marker> markers = List();
        List<PolylineWithMarkers> polylinesWithMarkers = List();
        bool isSelected = itinerary == selectedItinerary;
        for (int i = 0; i < itinerary.legs.length; i++) {
          PlanItineraryLeg leg = itinerary.legs[i];

          // Polyline
          List<LatLng> points = decodePolyline(leg.points);
          Polyline polyline = new Polyline(
            points: points,
            color: isSelected
                ? leg.mode == 'WALK' ? Colors.blue : Colors.green
                : Colors.grey,
            strokeWidth: isSelected ? 6.0 : 3.0,
            borderColor: Colors.white,
            borderStrokeWidth: 3.0,
            isDotted: leg.mode == 'WALK',
          );

          // Transfer marker
          if (isSelected && i < itinerary.legs.length - 1) {
            markers.add(
              buildTransferMarker(
                polyline.points[polyline.points.length - 1],
              ),
            );
          }

          // Bus marker
          if (leg.mode != 'WALK') {
            markers.add(
              buildBusMarker(
                midPointForPolyline(polyline),
                isSelected ? Colors.green : Colors.grey,
                leg,
                onTap: () => onTap(itinerary),
              ),
            );
          }
          polylinesWithMarkers.add(PolylineWithMarkers(polyline, markers));
        }
        itineraries.addAll({itinerary: polylinesWithMarkers});
      });
    }
    return itineraries;
  }
}

class PolylineWithMarkers {
  PolylineWithMarkers(this.polyline, this.markers);

  final Polyline polyline;
  final List<Marker> markers;
}
