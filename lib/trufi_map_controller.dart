import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_app/polyline_layer_circle.dart';

import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';

typedef void OnSelected(PlanItinerary itinerary);

class MapControllerPage extends StatefulWidget {
  final Plan plan;
  final OnSelected onSelected;
  final LatLng yourLocation;

  MapControllerPage({this.plan, this.onSelected, this.yourLocation});

  @override
  MapControllerPageState createState() {
    return MapControllerPageState();
  }
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Plan _plan;
  PlanItinerary _selectedItinerary;
  Map<PlanItinerary, List<PolylineWithMarker>> _itineraries = Map();
  List<Marker> _markers = List();
  List<Polyline> _polylines = List();
  List<Marker> _selectedMarkers = List();
  List<Polyline> _selectedPolylines = List();
  List<Polyline> _selectedWalkedPolylines = List();
  List<Polyline> _walkedPolylines = List();
  bool _needsCameraUpdate = true;

  void initState() {
    super.initState();
    mapController = MapController()
      ..onReady.then((_) {
        setState(() {});
      });
  }

  Widget build(BuildContext context) {
    _needsCameraUpdate = _needsCameraUpdate || widget.plan != _plan;
    _plan = widget.plan;
    _itineraries.clear();
    _markers.clear();
    _polylines.clear();
    _selectedMarkers.clear();
    _selectedPolylines.clear();
    _selectedWalkedPolylines.clear();
    _walkedPolylines.clear();

    var bounds = LatLngBounds();
    if (_plan != null) {
      if (_plan.from != null) {
        _markers.add(buildFromMarker(createLatLngWithPlanLocation(_plan.from)));
      }
      if (_plan.to != null) {
        _markers.add(buildToMarker(createLatLngWithPlanLocation(_plan.to)));
      }
      if (_plan.itineraries.isNotEmpty) {
        if (_selectedItinerary == null ||
            !_plan.itineraries.contains(_selectedItinerary)) {
          _selectedItinerary = _plan.itineraries.first;
        }
        _itineraries.addAll(
            createItineraries(_plan, _selectedItinerary, _setItinerary));
        _itineraries.forEach((itinerary, polylinesWithMarker) {
          bool isSelected = itinerary == _selectedItinerary;
          polylinesWithMarker.forEach((pws) {
            if (pws.marker != null) {
              if (isSelected) {
                _selectedMarkers.add(pws.marker);
              } else {
                _markers.add(pws.marker);
              }
            }
            if (isSelected) {
              itinerary.legs.forEach((leg) {
                if (leg.mode == 'WALK') {
                  print("walk selected");
                  _selectedWalkedPolylines.add(pws.polyline);
                } else {
                  print("bus selected");
                  _selectedPolylines.add(pws.polyline);
                }
              });
            } else {
              _polylines.add(pws.polyline);
            }
          });
        });
      }
    }
    _markers.forEach((marker) => bounds.extend(marker.point));
    _polylines.forEach((polyline) {
      polyline.points.forEach((point) {
        bounds.extend(point);
      });
    });
    if (widget.yourLocation != null) {
      _markers.add(buildYourLocationMarker(widget.yourLocation));
    }
    if (_needsCameraUpdate && mapController.ready) {
      if (bounds.isValid) {
        mapController.fitBounds(bounds);
      } else if (widget.yourLocation != null) {
        // TODO during the initial phase this code fails - don't know why
        try {
          mapController.move(widget.yourLocation, 15.0);
        } catch (e) {}
      }
      _needsCameraUpdate = false;
    }

    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: [
          Flexible(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                zoom: 5.0,
                maxZoom: 19.0,
                minZoom: 1.0,
                onTap: (point) => _handleOnMapTap(point),
              ),
              layers: [
                mapBoxTileLayerOptions(),
                PolylineLayerOptions(polylines: _polylines),
                PolylineLayerOptions(polylines: _selectedPolylines),
                PolylineCircleLayerOptions(polylines: _selectedWalkedPolylines),
                MarkerLayerOptions(markers: _markers),
                MarkerLayerOptions(markers: _selectedMarkers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _handleOnMapTap(LatLng point) {
    Polyline polyline = polylineHitTest(_polylines, point);
    if (polyline != null) {
      _setItinerary(_itineraryForPolyline(polyline));
    }
  }

  _setItinerary(PlanItinerary value) {
    setState(() {
      _selectedItinerary = value;
      if (widget.onSelected != null) {
        widget.onSelected(_selectedItinerary);
      }
    });
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    MapEntry<PlanItinerary, List<PolylineWithMarker>> entry =
    _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
  }

  MapEntry<PlanItinerary, List<PolylineWithMarker>> _itineraryEntryForPolyline(
      Polyline polyline) {
    return _itineraries.entries.firstWhere(
            (pair) =>
        pair.value.firstWhere((pwm) => pwm.polyline == polyline,
            orElse: () => null) !=
            null,
        orElse: () => null);
  }
}
