import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/alerts.dart';

typedef void OnSelected(PlanItinerary itinerary);

class MapControllerPage extends StatefulWidget {
  MapControllerPage({
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
  MapControllerPageState createState() {
    return MapControllerPageState();
  }
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
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
    mapController = MapController()
      ..onReady.then((_) {
        mapController.move(
          widget.initialPosition != null
              ? widget.initialPosition
              : LatLng(-17.4603761, -66.1860606),
          15.0,
        );
        setState(() {});
      });
  }

  Widget build(BuildContext context) {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);

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
    if (_needsCameraUpdate && mapController.ready) {
      if (bounds.isValid) {
        mapController.fitBounds(bounds);
        _needsCameraUpdate = false;
      }
    }

    // Layers
    double buttonMargin = 20.0;
    double buttonPadding = 10.0;
    double buttonSize = 50.0;
    List<Widget> children = <Widget>[];
    children.add(
      Positioned.fill(
        child: StreamBuilder<LatLng>(
          stream: locationProviderBloc.outLocationUpdate,
          builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
            if (snapshot.data != null) {
              _foregroundMarkers.add(buildYourLocationMarker(snapshot.data));
            }
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                zoom: 5.0,
                maxZoom: 19.0,
                minZoom: 1.0,
                onTap: _handleOnMapTap,
              ),
              layers: <LayerOptions>[
                tilehostingTileLayerOptions(),
                MarkerLayerOptions(markers: _backgroundMarkers),
                PolylineLayerOptions(polylines: _polylines),
                PolylineLayerOptions(polylines: _selectedPolylines),
                MarkerLayerOptions(markers: _foregroundMarkers),
                MarkerLayerOptions(markers: _selectedMarkers),
              ],
            );
          },
        ),
      ),
    );
    children.add(
      Positioned(
        top: buttonMargin,
        right: buttonMargin,
        width: buttonSize,
        height: buttonSize,
        child: _buildButton(
          Icons.my_location,
          () => _handleOnMyLocationButtonTapped(context),
        ),
      ),
    );
    if (_plan != null) {
      children.add(
        Positioned(
          top: buttonMargin + buttonPadding + buttonSize,
          right: buttonMargin,
          width: buttonSize,
          height: buttonSize,
          child: _buildButton(Icons.crop, _handleOnCropButtonTapped),
        ),
      );
    }
    return Stack(fit: StackFit.expand, children: children);
  }

  Widget _buildButton(IconData iconData, Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
        ),
        child: Icon(iconData),
      ),
    );
  }

  void _handleOnMapTap(LatLng point) {
    Polyline polyline = polylineHitTest(_polylines, point);
    if (polyline != null) {
      _setItinerary(_itineraryForPolyline(polyline));
    }
  }

  void _handleOnMyLocationButtonTapped(BuildContext context) async {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      mapController.move(lastLocation, 17.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  void _handleOnCropButtonTapped() {
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
