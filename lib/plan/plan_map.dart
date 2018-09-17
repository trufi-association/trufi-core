import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/alerts.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

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
  MapController _mapController;
  Plan _plan;
  PlanItinerary _selectedItinerary;
  Map<PlanItinerary, List<PolylineWithMarker>> _itineraries = Map();
  List<Marker> _backgroundMarkers = List();
  List<Marker> _foregroundMarkers = List();
  List<Polyline> _polylines = List();
  List<Marker> _selectedMarkers = List();
  List<Polyline> _selectedPolylines = List();
  bool _needsCameraUpdate = true;

  void initState() {
    super.initState();
    _mapController = MapController()
      ..onReady.then((_) {
        _mapController.move(
          widget.initialPosition != null
              ? widget.initialPosition
              : LatLng(-17.4603761, -66.1860606),
          15.0,
        );
        setState(() {});
      });
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
    var bounds = LatLngBounds();

    // Build markers and polylines
    if (_plan != null) {
      if (_plan.from != null) {
        LatLng point = createLatLngWithPlanLocation(_plan.from);
        _backgroundMarkers.add(buildFromMarker(point));
        bounds.extend(point);
      }
      if (_plan.to != null) {
        LatLng point = createLatLngWithPlanLocation(_plan.to);
        _foregroundMarkers.add(buildToMarker(point));
        bounds.extend(point);
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
            if (polylineWithMarker.marker != null) {
              if (isSelected) {
                _selectedMarkers.add(polylineWithMarker.marker);
                bounds.extend(polylineWithMarker.marker.point);
              } else {
                _foregroundMarkers.add(polylineWithMarker.marker);
              }
            }
            if (isSelected) {
              _selectedPolylines.add(polylineWithMarker.polyline);
              polylineWithMarker.polyline.points.forEach((point) {
                bounds.extend(point);
              });
            } else {
              _polylines.add(polylineWithMarker.polyline);
            }
          });
        });
      }
    }
    if (_needsCameraUpdate && _mapController.ready) {
      if (bounds.isValid) {
        _mapController.fitBounds(bounds);
        _needsCameraUpdate = false;
      }
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: TrufiMap(
            mapController: _mapController,
            mapOptions: MapOptions(
              zoom: 5.0,
              maxZoom: 19.0,
              minZoom: 1.0,
              onTap: _handleOnMapTap,
            ),
            layers: <LayerOptions>[
              MarkerLayerOptions(markers: _backgroundMarkers),
              PolylineLayerOptions(polylines: _polylines),
              PolylineLayerOptions(polylines: _selectedPolylines),
              MarkerLayerOptions(markers: _foregroundMarkers),
              MarkerLayerOptions(markers: _selectedMarkers),
            ],
            initialPosition: widget.initialPosition,
          ),
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
        _buildFloatingActionButton(
          context,
          Icons.crop_free,
          _handleOnCropTap,
        ),
        _buildFloatingActionButton(
          context,
          Icons.my_location,
          _handleOnMyLocationTap,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    IconData iconData,
    Function onPressed,
  ) {
    return ScaleTransition(
      scale: AlwaysStoppedAnimation<double>(0.8),
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(iconData),
        onPressed: onPressed,
        heroTag: null,
      ),
    );
  }

  void _handleOnMapTap(LatLng point) {
    Polyline polyline = polylineHitTest(_polylines, point);
    if (polyline != null) {
      _setItinerary(_itineraryForPolyline(polyline));
    }
  }

  void _handleOnMyLocationTap() async {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _mapController.move(lastLocation, 17.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  void _handleOnCropTap() {
    setState(() {
      _needsCameraUpdate = true;
    });
  }

  void _setItinerary(PlanItinerary value) {
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
}
