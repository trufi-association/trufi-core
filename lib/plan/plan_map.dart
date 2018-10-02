import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
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
  final _cropButtonKey = GlobalKey<CropButtonState>();
  final _subscriptions = CompositeSubscription();
  final _trufiOnlineMapController = TrufiOnlineMapController();
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
      _trufiOnlineMapController.outMapReady.listen((_) {
        setState(() {
          _needsCameraUpdate = true;
        });
      }),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    _trufiOnlineMapController.dispose();
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
    if (_needsCameraUpdate && _trufiOnlineMapController.mapController.ready) {
      if (_selectedBounds.isValid) {
        _trufiOnlineMapController.mapController.fitBounds(_selectedBounds);
        _needsCameraUpdate = false;
      }
    }
    return Stack(
      children: <Widget>[
        TrufiOnlineMap(
          key: ValueKey("PlanMap"),
          trufiOnlineMapController: _trufiOnlineMapController,
          onTap: _handleOnMapTap,
          onPositionChanged: _handleOnMapPositionChanged,
          layerOptionsBuilder: (context) {
            return <LayerOptions>[
              PolylineLayerOptions(polylines: _polylines),
              MarkerLayerOptions(markers: _backgroundMarkers),
              PolylineLayerOptions(polylines: _selectedPolylines),
              MarkerLayerOptions(markers: _selectedMarkers),
              _trufiOnlineMapController.yourLocationLayer,
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
        CropButton(
          key: _cropButtonKey,
          iconData: Icons.crop_free,
          onPressed: _handleOnCropTap,
        ),
        MyLocationButton(
          iconData: Icons.my_location,
          onPressed: _handleOnMyLocationTap,
        ),
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

  void _handleOnMyLocationTap() async {
    final locationProviderBloc = LocationProviderBloc.of(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _trufiOnlineMapController.mapController.move(lastLocation, 17.0);
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
      _needsCameraUpdate = true;
      if (widget.onSelected != null) {
        widget.onSelected(_selectedItinerary);
      }
    });
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    MapEntry<PlanItinerary, List<PolylineWithMarkers>> entry =
        _itineraryEntryForPolyline(polyline);
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
}

class CropButton extends StatefulWidget {
  CropButton({
    Key key,
    @required this.iconData,
    @required this.onPressed,
  }) : super(key: key);

  final IconData iconData;
  final Function onPressed;

  @override
  CropButtonState createState() => CropButtonState();
}

class CropButtonState extends State<CropButton>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 0.8).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(widget.iconData),
        onPressed: _handleOnPressed,
        heroTag: null,
      ),
    );
  }

  void _handleOnPressed() {
    widget.onPressed();
    setVisible(false);
  }

  bool get isVisible => _visible;

  void setVisible(bool visible) {
    if (_visible != visible) {
      setState(() {
        _visible = visible;
        if (visible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }
}

class MyLocationButton extends StatelessWidget {
  MyLocationButton({
    this.iconData,
    this.onPressed,
  });

  final IconData iconData;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(iconData),
        onPressed: onPressed,
        heroTag: null,
      ),
    );
  }
}
