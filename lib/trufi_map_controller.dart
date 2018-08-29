import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';

typedef void OnSelected(PlanItinerary itinerary);

class MapControllerPage extends StatefulWidget {
  final Plan plan;
  final OnSelected onSelected;

  MapControllerPage({this.plan, this.onSelected});

  @override
  MapControllerPageState createState() {
    return MapControllerPageState();
  }
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Plan _plan;
  Map<PlanItinerary, List<Polyline>> _itineraries;
  PlanItinerary _selectedItinerary;
  List<Marker> _markers = <Marker>[];
  List<Polyline> _polylines = <Polyline>[];

  void initState() {
    super.initState();
    mapController = MapController();
  }

  Widget build(BuildContext context) {
    bool needsFitBounds = widget.plan != null && widget.plan != _plan;
    _plan = widget.plan;
    _itineraries = Map();
    _markers = List();
    _polylines = List();
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
        _itineraries = createItineraries(_plan, _selectedItinerary);
        _itineraries.forEach((_, polylines) => _polylines.addAll(polylines));
      }
    }
    _markers.forEach((marker) => bounds.extend(marker.point));
    _polylines.forEach((polyline) {
      polyline.points.forEach((point) {
        bounds.extend(point);
      });
    });
    if (needsFitBounds && bounds.isValid) {
      mapController.fitBounds(bounds);
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
                MarkerLayerOptions(markers: _markers),
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
      setState(() {
        _selectedItinerary = _itineraryForPolyline(polyline);
        if (widget.onSelected != null) {
          widget.onSelected(_selectedItinerary);
        }
      });
    }
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    MapEntry<PlanItinerary, List<Polyline>> entry =
        _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
  }

  MapEntry<PlanItinerary, List<Polyline>> _itineraryEntryForPolyline(
      Polyline polyline) {
    return _itineraries.entries.firstWhere(
        (pair) =>
            pair.value.firstWhere((p) => p == polyline, orElse: () => null) !=
            null,
        orElse: () => null);
  }
}
